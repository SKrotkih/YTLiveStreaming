import Foundation

/// One observation of a broadcast and its bound stream.
public struct BroadcastSnapshot: Sendable, Equatable {
    public let broadcast: LiveBroadcastStreamModel
    /// `nil` when no stream is bound (or the `contentDetails` part is missing).
    public let stream: LiveStreamModel?
    public let observedAt: Date

    public var lifeCycleStatus: LifeCycleStatus { broadcast.lifeCycleStatus }
    public var streamStatus: StreamStatus { stream?.streamStatus ?? .unknown }
    public var streamHealth: StreamHealth { stream?.health ?? .unknown }
    /// `true` when YouTube is receiving data from the encoder.
    public var isEncoderSending: Bool { stream?.isReceivingData ?? false }
}

/// Events emitted by ``YouTubeLiveClient/monitor(broadcastID:options:)``.
public enum BroadcastEvent: Sendable {
    /// Emitted on every poll, whether or not anything changed.
    case snapshot(BroadcastSnapshot)
    /// The encoder started sending data (`streamStatus` became `.active`).
    case encoderConnected
    /// The monitor asked YouTube to change the broadcast status.
    case transitionRequested(BroadcastTransition)
    /// A requested transition was rejected; polling continues. Typical reasons:
    /// `errorStreamInactive`, `invalidTransition`, `redundantTransition`.
    case transitionFailed(BroadcastTransition, YouTubeLiveError)
    /// `lifeCycleStatus` reached `.testing`.
    case testing
    /// `lifeCycleStatus` reached `.live`. Emitted once.
    case live
    /// A poll failed with a recoverable error; polling continues.
    case pollFailed(YouTubeLiveError)
    /// `lifeCycleStatus` reached `.complete` (or `.revoked` / `.abandoned`). The stream ends after this.
    case ended(LifeCycleStatus)
}

/// Tuning for ``YouTubeLiveClient/monitor(broadcastID:options:)``.
public struct MonitorOptions: Sendable {
    /// Seconds between polls. YouTube's quota is 10 000 units/day; each poll costs 2 units
    /// (one `liveBroadcasts.list` + one `liveStreams.list`), so 3 s ≈ 2 400 units/hour.
    public var pollInterval: TimeInterval
    /// When `true`, the monitor transitions the broadcast towards `.live` as soon as the
    /// encoder is sending: `ready → testing → live` when the monitor stream is enabled,
    /// `ready → live` otherwise. Set `false` to only observe (e.g. for `enableAutoStart` broadcasts).
    public var autoGoLive: Bool
    /// Stop after this many consecutive failed polls by throwing the last error.
    public var maxConsecutivePollFailures: Int
    /// Finish the stream once the broadcast is complete.
    public var stopWhenEnded: Bool

    public init(
        pollInterval: TimeInterval = 3,
        autoGoLive: Bool = true,
        maxConsecutivePollFailures: Int = 5,
        stopWhenEnded: Bool = true
    ) {
        self.pollInterval = max(pollInterval, 0.01)
        self.autoGoLive = autoGoLive
        self.maxConsecutivePollFailures = max(maxConsecutivePollFailures, 1)
        self.stopWhenEnded = stopWhenEnded
    }
}

public extension YouTubeLiveClient {
    /// Observes a broadcast until it ends (or the consumer cancels), optionally driving it live.
    ///
    /// ```swift
    /// for try await event in youtube.monitor(broadcastID: id) {
    ///     switch event {
    ///     case .snapshot(let s): statusLabel.text = "\(s.lifeCycleStatus) / \(s.streamStatus)"
    ///     case .live:            showOnAirBadge()
    ///     case .ended:           dismiss()
    ///     default:               break
    ///     }
    /// }
    /// ```
    /// Cancelling the consuming task stops polling. Errors that end the stream are
    /// `YouTubeLiveError.unauthorized`, `.notFound`, or repeated poll failures.
    func monitor(broadcastID: String, options: MonitorOptions = MonitorOptions()) -> AsyncThrowingStream<BroadcastEvent, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await self.runMonitor(broadcastID: broadcastID, options: options) { event in
                        continuation.yield(event)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Drives a broadcast to `.live` and returns once it is there.
    ///
    /// Waits for the encoder to connect, performs the required transitions, and returns the
    /// live broadcast. Throws ``YouTubeLiveError/timeout`` if `timeout` elapses first.
    @discardableResult
    func goLive(
        broadcastID: String,
        timeout: TimeInterval = 120,
        pollInterval: TimeInterval = 3
    ) async throws -> LiveBroadcastStreamModel {
        let options = MonitorOptions(pollInterval: pollInterval, autoGoLive: true, stopWhenEnded: true)
        let deadline = Date().addingTimeInterval(timeout)
        var latest: LiveBroadcastStreamModel?
        for try await event in monitor(broadcastID: broadcastID, options: options) {
            switch event {
            case .snapshot(let snapshot):
                latest = snapshot.broadcast
                if snapshot.lifeCycleStatus == .live { return snapshot.broadcast }
            case .ended(let status):
                throw YouTubeLiveError.broadcastEnded(status)
            default:
                break
            }
            if Date() >= deadline {
                throw YouTubeLiveError.timeout(lastKnown: latest)
            }
        }
        throw YouTubeLiveError.timeout(lastKnown: latest)
    }
}

// MARK: - Implementation

extension YouTubeLiveClient {
    /// Polls until the broadcast ends or the task is cancelled, emitting events via `emit`.
    func runMonitor(
        broadcastID: String,
        options: MonitorOptions,
        emit: @Sendable (BroadcastEvent) -> Void
    ) async throws {
        var wasEncoderSending = false
        var announcedTesting = false
        var announcedLive = false
        // Lifecycle state we last requested a transition from, and how many polls ago.
        var requestedFrom: LifeCycleStatus?
        var pollsSinceRequest = 0
        var consecutiveFailures = 0

        while !Task.isCancelled {
            let snapshot: BroadcastSnapshot
            do {
                snapshot = try await poll(broadcastID: broadcastID)
                consecutiveFailures = 0
            } catch let error as YouTubeLiveError {
                switch error {
                case .unauthorized, .notFound, .missingAccessToken:
                    throw error
                default:
                    consecutiveFailures += 1
                    emit(.pollFailed(error))
                    if consecutiveFailures >= options.maxConsecutivePollFailures { throw error }
                    try await sleep(options.pollInterval)
                    continue
                }
            }

            emit(.snapshot(snapshot))

            if snapshot.isEncoderSending && !wasEncoderSending {
                emit(.encoderConnected)
            }
            wasEncoderSending = snapshot.isEncoderSending

            let status = snapshot.lifeCycleStatus
            if status == .testing && !announcedTesting {
                announcedTesting = true
                emit(.testing)
            }
            if status == .live && !announcedLive {
                announcedLive = true
                emit(.live)
            }
            if status == .complete || status == .revoked || status == .abandoned {
                emit(.ended(status))
                if options.stopWhenEnded { return }
            }

            // A requested transition has landed when the lifecycle state moved on. If YouTube
            // silently stayed put for a few polls, allow another attempt.
            if let from = requestedFrom {
                pollsSinceRequest += 1
                if status != from || pollsSinceRequest >= Self.pollsBeforeRetry {
                    requestedFrom = nil
                }
            }

            if options.autoGoLive, requestedFrom == nil, snapshot.isEncoderSending,
               let next = Self.nextTransition(from: status, monitorStreamEnabled: snapshot.monitorStreamEnabled) {
                emit(.transitionRequested(next))
                do {
                    _ = try await transition(broadcastID: broadcastID, to: next)
                    requestedFrom = status
                    pollsSinceRequest = 0
                } catch let error as YouTubeLiveError {
                    switch error {
                    case .unauthorized, .notFound, .missingAccessToken:
                        throw error
                    default:
                        emit(.transitionFailed(next, error))
                    }
                }
            }

            try await sleep(options.pollInterval)
        }
    }

    private func poll(broadcastID: String) async throws -> BroadcastSnapshot {
        let broadcast = try await self.broadcast(id: broadcastID)
        var stream: LiveStreamModel?
        if let streamID = broadcast.contentDetails?.boundStreamId, !streamID.isEmpty {
            stream = try await self.stream(id: streamID)
        }
        return BroadcastSnapshot(broadcast: broadcast, stream: stream, observedAt: Date())
    }

    /// `ready → testing` (monitor stream on) or `ready → live` (off); `testing → live`.
    static func nextTransition(from status: LifeCycleStatus, monitorStreamEnabled: Bool) -> BroadcastTransition? {
        switch status {
        case .ready:
            return monitorStreamEnabled ? .testing : .live
        case .testing:
            return .live
        default:
            return nil
        }
    }

    /// Polls to wait for a requested transition to show up before requesting it again.
    static let pollsBeforeRetry = 3

    private func sleep(_ seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

extension BroadcastSnapshot {
    /// YouTube requires `ready → testing → live` when the monitor stream is enabled (the default).
    var monitorStreamEnabled: Bool {
        broadcast.contentDetails?.monitorStream?.enableMonitorStream ?? true
    }
}
