import Foundation

// MARK: - Purge (delete without leaving traces)

/// What ``YouTubeLiveClient/purgeBroadcast(id:deleteBoundStream:)`` actually did.
public struct PurgeResult: Sendable, Equatable {
    /// The broadcast (or video) ID that was purged.
    public let broadcastID: String
    /// `true` when the broadcast had to be ended (`transition(.complete)`) first.
    public let endedFirst: Bool
    /// `true` when `liveBroadcasts.delete` was refused and the recording was removed with
    /// `videos.delete` instead (typical for completed broadcasts).
    public let deletedAsVideo: Bool
    /// The bound stream that was deleted, if any.
    public let deletedStreamID: String?
}

public extension YouTubeLiveClient {
    /// `videos.delete`. A broadcast is also a video with the same ID, so this removes the
    /// recording of a completed broadcast when `liveBroadcasts.delete` refuses it.
    func deleteVideo(id: String) async throws {
        try await performNoContent(Endpoint(
            method: .delete,
            path: "videos",
            query: [URLQueryItem(name: "id", value: id)]
        ))
    }

    /// Removes a broadcast and everything YouTube keeps for it:
    ///
    /// 1. a broadcast that is still going (`testing` / `live` / …) is ended first;
    /// 2. `liveBroadcasts.delete`; when YouTube answers `liveBroadcastDeletionNotAllowed`
    ///    (completed broadcasts) the recording is deleted with `videos.delete` instead;
    /// 3. the bound `liveStream` is deleted too unless `deleteBoundStream` is `false` or the
    ///    stream is marked reusable (it may serve other broadcasts).
    ///
    /// A broadcast that no longer exists is not an error — the goal is "gone", and it is.
    @discardableResult
    func purgeBroadcast(id: String, deleteBoundStream: Bool = true) async throws -> PurgeResult {
        // 1. Look it up (for the bound stream and the life-cycle status).
        let broadcast: LiveBroadcastStreamModel?
        do {
            broadcast = try await self.broadcast(id: id)
        } catch let error as YouTubeLiveError where error.isNotFound {
            broadcast = nil
        }
        guard let broadcast else {
            return PurgeResult(broadcastID: id, endedFirst: false, deletedAsVideo: false, deletedStreamID: nil)
        }

        // 2. End it if it is still running.
        var endedFirst = false
        switch broadcast.lifeCycleStatus {
        case .testStarting, .testing, .liveStarting, .live:
            try await transition(broadcastID: id, to: .complete)
            endedFirst = true
        default:
            break
        }

        // 3. Delete the broadcast; fall back to deleting the video (same ID).
        var deletedAsVideo = false
        do {
            try await deleteBroadcast(id: id)
        } catch let error as YouTubeLiveError where error.isNotFound {
            // Already gone.
        } catch let error as YouTubeLiveError where error.apiError?.reason == "liveBroadcastDeletionNotAllowed" {
            try await deleteVideoIgnoringNotFound(id: id)
            deletedAsVideo = true
        }
        // A broadcast that has run leaves a recording; make sure it is gone as well.
        if !deletedAsVideo, endedFirst || broadcast.lifeCycleStatus == .complete {
            try await deleteVideoIgnoringNotFound(id: id)
        }

        // 4. Drop the bound stream unless it is meant to be reused.
        var deletedStreamID: String?
        if deleteBoundStream, let streamID = broadcast.contentDetails?.boundStreamId {
            let reusable: Bool
            do {
                reusable = try await stream(id: streamID).contentDetails?.isReusable ?? false
            } catch let error as YouTubeLiveError where error.isNotFound {
                reusable = true // nothing to delete
            }
            if !reusable {
                do {
                    try await deleteStream(id: streamID)
                    deletedStreamID = streamID
                } catch let error as YouTubeLiveError where error.isNotFound {
                    // Already gone.
                }
            }
        }

        return PurgeResult(broadcastID: id, endedFirst: endedFirst,
                           deletedAsVideo: deletedAsVideo, deletedStreamID: deletedStreamID)
    }

    /// ``purgeBroadcast(id:deleteBoundStream:)`` for several IDs, run concurrently. Every ID
    /// is attempted; the first failure is thrown afterwards.
    @discardableResult
    func purgeBroadcasts(ids: [String], deleteBoundStream: Bool = true) async throws -> [PurgeResult] {
        try await withThrowingTaskGroup(of: PurgeResult.self) { group in
            for id in ids {
                group.addTask { try await self.purgeBroadcast(id: id, deleteBoundStream: deleteBoundStream) }
            }
            var results: [PurgeResult] = []
            var firstError: (any Error)?
            while let result = await group.nextResult() {
                switch result {
                case .success(let purge): results.append(purge)
                case .failure(let error): if firstError == nil { firstError = error }
                }
            }
            if let firstError { throw firstError }
            return results
        }
    }

    private func deleteVideoIgnoringNotFound(id: String) async throws {
        do {
            try await deleteVideo(id: id)
        } catch let error as YouTubeLiveError where error.isNotFound {
            // Already gone.
        }
    }
}

private extension YouTubeLiveError {
    var isNotFound: Bool {
        if case .notFound = self { return true }
        return false
    }
}
