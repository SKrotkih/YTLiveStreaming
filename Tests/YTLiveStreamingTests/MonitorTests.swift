import Foundation
import XCTest
@testable import YTLiveStreaming

/// A stateful stand-in for YouTube's broadcast/stream endpoints, routed by URL path.
actor FakeYouTube: HTTPTransport {
    var lifeCycle: LifeCycleStatus
    var streamStatus: StreamStatus
    var monitorStreamEnabled: Bool
    var boundStreamID: String? = "stream-1"
    /// If set, every request fails with this HTTP status until cleared.
    var outage: Int?
    /// Refuse this many transition requests with `errorStreamInactive` before honouring them.
    var refuseTransitions = 0

    private(set) var transitions: [BroadcastTransition] = []
    private(set) var polls = 0

    init(lifeCycle: LifeCycleStatus = .ready, streamStatus: StreamStatus = .inactive, monitorStreamEnabled: Bool = true) {
        self.lifeCycle = lifeCycle
        self.streamStatus = streamStatus
        self.monitorStreamEnabled = monitorStreamEnabled
    }

    func set(lifeCycle: LifeCycleStatus? = nil, streamStatus: StreamStatus? = nil) {
        if let lifeCycle { self.lifeCycle = lifeCycle }
        if let streamStatus { self.streamStatus = streamStatus }
    }

    func setOutage(_ status: Int?) { outage = status }
    func refuseNextTransitions(_ count: Int) { refuseTransitions = count }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let path = request.url?.path ?? ""
        let query = request.queryItems
        if let outage {
            return respond(request, status: outage, json: ["error": ["code": outage, "message": "outage"]])
        }
        switch path {
        case "/youtube/v3/liveBroadcasts/transition":
            let target = BroadcastTransition(rawValue: query["broadcastStatus"] ?? "")!
            transitions.append(target)
            let refuse = refuseTransitions > 0
            if refuse { refuseTransitions -= 1 }
            guard (streamStatus == .active && !refuse) || target == .complete else {
                return respond(request, status: 403, json: [
                    "error": ["code": 403, "message": "Stream is inactive",
                              "errors": [["reason": "errorStreamInactive", "domain": "youtube.liveBroadcast"]]]
                ])
            }
            switch target {
            case .testing: lifeCycle = .testing
            case .live: lifeCycle = .live
            case .complete: lifeCycle = .complete
            }
            return respond(request, status: 200, json: broadcastJSON)
        case "/youtube/v3/liveBroadcasts":
            polls += 1
            return respond(request, status: 200, json: [
                "kind": "youtube#liveBroadcastListResponse", "etag": "e", "items": [broadcastJSON]
            ])
        case "/youtube/v3/liveStreams":
            return respond(request, status: 200, json: [
                "kind": "youtube#liveStreamListResponse", "etag": "e", "items": [streamJSON]
            ])
        default:
            XCTFail("unexpected path \(path)")
            throw YouTubeLiveError.invalidResponse
        }
    }

    private var broadcastJSON: [String: Any] {
        var contentDetails: [String: Any] = [
            "monitorStream": ["enableMonitorStream": monitorStreamEnabled, "broadcastStreamDelayMs": 0]
        ]
        if let boundStreamID { contentDetails["boundStreamId"] = boundStreamID }
        return [
            "kind": "youtube#liveBroadcast", "etag": "e", "id": "B1",
            "snippet": ["publishedAt": "2024-06-01T00:00:00Z", "channelId": "UC1", "title": "t", "description": ""],
            "status": ["lifeCycleStatus": lifeCycle.rawValue, "privacyStatus": "public"],
            "contentDetails": contentDetails
        ]
    }

    private var streamJSON: [String: Any] {
        [
            "kind": "youtube#liveStream", "etag": "e", "id": "stream-1",
            "status": ["streamStatus": streamStatus.rawValue, "healthStatus": ["status": streamStatus == .active ? "good" : "noData"]]
        ]
    }

    private func respond(_ request: URLRequest, status: Int, json: [String: Any]) -> (Data, HTTPURLResponse) {
        let data = try! JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

private extension BroadcastEvent {
    var label: String {
        switch self {
        case .snapshot(let s): return "snapshot(\(s.lifeCycleStatus.rawValue)/\(s.streamStatus.rawValue))"
        case .encoderConnected: return "encoderConnected"
        case .transitionRequested(let t): return "transitionRequested(\(t.rawValue))"
        case .transitionFailed(let t, _): return "transitionFailed(\(t.rawValue))"
        case .testing: return "testing"
        case .live: return "live"
        case .pollFailed: return "pollFailed"
        case .ended(let s): return "ended(\(s.rawValue))"
        }
    }
}

final class MonitorTests: XCTestCase {
    private let fast = MonitorOptions(pollInterval: 0.01)

    private func client(_ yt: FakeYouTube) -> YouTubeLiveClient {
        YouTubeLiveClient(tokenProvider: StaticTokenProvider("t"), configuration: .init(bundleIdentifier: nil), transport: yt)
    }

    func testDrivesReadyThroughTestingToLiveWithMonitorStream() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .inactive, monitorStreamEnabled: true)
        var labels: [String] = []

        for try await event in client(yt).monitor(broadcastID: "B1", options: fast) {
            labels.append(event.label)
            switch event {
            case .snapshot(let s) where s.streamStatus == .inactive:
                await yt.set(streamStatus: .active)          // encoder connects after the first poll
            case .live:
                await yt.set(lifeCycle: .complete)           // someone ends the broadcast
            default:
                break
            }
        }

        let transitions = await yt.transitions
        XCTAssertEqual(transitions, [.testing, .live])
        // Snapshots repeat while the consumer reacts, so compare the state-change events only.
        XCTAssertEqual(labels.filter { !$0.hasPrefix("snapshot") }, [
            "encoderConnected", "transitionRequested(testing)", "testing",
            "transitionRequested(live)", "live", "ended(complete)"
        ])
        XCTAssertEqual(labels.first, "snapshot(ready/inactive)")
        XCTAssertEqual(labels.last, "ended(complete)")
    }

    func testGoesStraightToLiveWithoutMonitorStream() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .active, monitorStreamEnabled: false)
        var sawLive = false

        for try await event in client(yt).monitor(broadcastID: "B1", options: fast) {
            if case .live = event {
                sawLive = true
                await yt.set(lifeCycle: .complete)
            }
        }

        XCTAssertTrue(sawLive)
        let transitions = await yt.transitions
        XCTAssertEqual(transitions, [.live])
    }

    func testDoesNotTransitionWhileEncoderIsSilent() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .inactive)
        var snapshots = 0

        for try await event in client(yt).monitor(broadcastID: "B1", options: fast) {
            if case .snapshot = event {
                snapshots += 1
                if snapshots == 4 { await yt.set(lifeCycle: .complete) }
            }
        }

        let transitions = await yt.transitions
        XCTAssertTrue(transitions.isEmpty)
    }

    func testAutoGoLiveOffOnlyObserves() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .active, monitorStreamEnabled: false)
        var snapshots = 0
        let options = MonitorOptions(pollInterval: 0.01, autoGoLive: false)

        for try await event in client(yt).monitor(broadcastID: "B1", options: options) {
            if case .snapshot = event {
                snapshots += 1
                if snapshots == 3 { await yt.set(lifeCycle: .complete) }
            }
        }

        let transitions = await yt.transitions
        XCTAssertTrue(transitions.isEmpty)
    }

    func testRejectedTransitionIsReportedAndRetriedLater() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .active, monitorStreamEnabled: false)
        await yt.refuseNextTransitions(1)
        var failures = 0
        var requested = 0

        for try await event in client(yt).monitor(broadcastID: "B1", options: fast) {
            switch event {
            case .transitionRequested:
                requested += 1
            case .transitionFailed(let t, let error):
                failures += 1
                XCTAssertEqual(t, .live)
                XCTAssertEqual(error.apiError?.reason, "errorStreamInactive")
            case .live:
                await yt.set(lifeCycle: .complete)
            default:
                break
            }
        }

        XCTAssertEqual(failures, 1)
        XCTAssertEqual(requested, 2, "a refused transition is retried on the next poll")
        let lifeCycle = await yt.lifeCycle
        XCTAssertEqual(lifeCycle, .complete)
    }

    func testTransientPollFailuresAreReportedThenRecovered() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .inactive)
        await yt.setOutage(503)
        var pollFailures = 0
        var snapshots = 0
        let options = MonitorOptions(pollInterval: 0.01, maxConsecutivePollFailures: 50)

        for try await event in client(yt).monitor(broadcastID: "B1", options: options) {
            switch event {
            case .pollFailed(let error):
                pollFailures += 1
                XCTAssertEqual(error.statusCode, 503)
                if pollFailures == 2 { await yt.setOutage(nil) }
            case .snapshot:
                snapshots += 1
                if snapshots == 2 { await yt.set(lifeCycle: .complete) }
            default:
                break
            }
        }

        XCTAssertGreaterThanOrEqual(pollFailures, 2, "failures are reported")
        XCTAssertLessThan(pollFailures, 50, "and polling recovered instead of throwing")
        XCTAssertGreaterThanOrEqual(snapshots, 2)
    }

    func testPersistentPollFailureThrows() async throws {
        let yt = FakeYouTube()
        await yt.setOutage(500)
        let options = MonitorOptions(pollInterval: 0.01, maxConsecutivePollFailures: 3)
        var pollFailures = 0

        do {
            for try await event in client(yt).monitor(broadcastID: "B1", options: options) {
                if case .pollFailed = event { pollFailures += 1 }
            }
            XCTFail("expected the stream to throw")
        } catch let error as YouTubeLiveError {
            XCTAssertEqual(error.statusCode, 500)
        }
        XCTAssertEqual(pollFailures, 3)
    }

    func testNotFoundWithinGracePeriodIsRetried() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .inactive)
        await yt.setOutage(404)
        let options = MonitorOptions(pollInterval: 0.01, autoGoLive: false, notFoundGracePeriod: 5)
        var notFoundPolls = 0
        var snapshots = 0

        for try await event in client(yt).monitor(broadcastID: "B1", options: options) {
            switch event {
            case .pollFailed(let error):
                XCTAssertEqual(error.statusCode, 404)
                notFoundPolls += 1
                if notFoundPolls == 3 { await yt.setOutage(nil) }   // YouTube "indexes" the broadcast
            case .snapshot:
                snapshots += 1
                if snapshots == 2 { await yt.set(lifeCycle: .complete) }
            default:
                break
            }
        }
        XCTAssertEqual(notFoundPolls, 3, "404s inside the grace period are reported, not thrown")
        XCTAssertGreaterThanOrEqual(snapshots, 2)
    }

    func testNotFoundAfterGracePeriodThrows() async throws {
        let yt = FakeYouTube()
        await yt.setOutage(404)
        let options = MonitorOptions(pollInterval: 0.01, notFoundGracePeriod: 0)

        do {
            for try await _ in client(yt).monitor(broadcastID: "B1", options: options) {}
            XCTFail("expected notFound")
        } catch YouTubeLiveError.notFound {
            // ok
        }
    }

    func testUnauthorizedEndsTheStreamImmediately() async throws {
        let yt = FakeYouTube()
        await yt.setOutage(401)

        do {
            for try await _ in client(yt).monitor(broadcastID: "B1", options: fast) {}
            XCTFail("expected unauthorized")
        } catch YouTubeLiveError.unauthorized {
            // ok
        }
    }

    func testCancellationStopsPolling() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .inactive)
        let consumer = Task {
            var count = 0
            for try await event in self.client(yt).monitor(broadcastID: "B1", options: self.fast) {
                if case .snapshot = event { count += 1 }
            }
            return count
        }
        try await Task.sleep(nanoseconds: 80_000_000)
        consumer.cancel()
        _ = try? await consumer.value

        try await Task.sleep(nanoseconds: 50_000_000) // let an in-flight poll drain
        let pollsAtCancel = await yt.polls
        try await Task.sleep(nanoseconds: 100_000_000)
        let pollsLater = await yt.polls
        XCTAssertEqual(pollsAtCancel, pollsLater, "polling must stop after the consumer is cancelled")
        XCTAssertGreaterThan(pollsAtCancel, 0)
    }

    func testGoLiveReturnsLiveBroadcast() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .active, monitorStreamEnabled: true)

        let live = try await client(yt).goLive(broadcastID: "B1", timeout: 5, pollInterval: 0.01)

        XCTAssertEqual(live.lifeCycleStatus, .live)
        let transitions = await yt.transitions
        XCTAssertEqual(transitions, [.testing, .live])
    }

    func testGoLiveTimesOut() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .inactive)

        do {
            _ = try await client(yt).goLive(broadcastID: "B1", timeout: 0.1, pollInterval: 0.01)
            XCTFail("expected timeout")
        } catch YouTubeLiveError.timeout(let last) {
            XCTAssertEqual(last?.lifeCycleStatus, .ready)
        }
        let transitions = await yt.transitions
        XCTAssertTrue(transitions.isEmpty)
    }

    func testGoLiveFailsWhenBroadcastEnds() async throws {
        let yt = FakeYouTube(lifeCycle: .complete, streamStatus: .inactive)

        do {
            _ = try await client(yt).goLive(broadcastID: "B1", timeout: 5, pollInterval: 0.01)
            XCTFail("expected broadcastEnded")
        } catch YouTubeLiveError.broadcastEnded(let status) {
            XCTAssertEqual(status, .complete)
        }
    }

    func testUnboundBroadcastPollsWithoutStream() async throws {
        let yt = FakeYouTube(lifeCycle: .ready, streamStatus: .active)
        await yt.unbind()
        var sawSnapshotWithoutStream = false

        for try await event in client(yt).monitor(broadcastID: "B1", options: fast) {
            if case .snapshot(let s) = event {
                XCTAssertNil(s.stream)
                XCTAssertFalse(s.isEncoderSending)
                sawSnapshotWithoutStream = true
                await yt.set(lifeCycle: .complete)
            }
        }

        XCTAssertTrue(sawSnapshotWithoutStream)
        let transitions = await yt.transitions
        XCTAssertTrue(transitions.isEmpty, "no stream bound → never try to go live")
    }
}

extension FakeYouTube {
    func unbind() { boundStreamID = nil }
}
