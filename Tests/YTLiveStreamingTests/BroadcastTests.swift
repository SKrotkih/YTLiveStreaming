import Foundation
import XCTest
@testable import YTLiveStreaming

final class BroadcastTests: XCTestCase {

    // MARK: Decoding

    func testListDecodesAllLifecycleStates() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        let client = makeClient(transport)

        let page = try await client.broadcasts(.all)

        XCTAssertEqual(page.items.count, 3)
        XCTAssertEqual(page.nextPageToken, "CAUQAA")
        XCTAssertEqual(page.pageInfo?.totalResults, 3)

        let live = page.items[0]
        XCTAssertEqual(live.id, "abc123LIVE")
        XCTAssertTrue(live.isLive)
        XCTAssertEqual(live.status?.privacyStatus, .public)
        XCTAssertEqual(live.contentDetails?.boundStreamId, "stream-1")
        XCTAssertEqual(live.contentDetails?.latencyPreference, .normal)
        XCTAssertEqual(live.snippet.liveChatId, "Cg0KC2FiYzEyM0xJVkU")
        XCTAssertEqual(live.snippet.thumbnails?.best?.width, 480)
        XCTAssertEqual(live.watchURL?.absoluteString, "https://www.youtube.com/watch?v=abc123LIVE")

        // Fractional and non-fractional timestamps both decode.
        XCTAssertEqual(live.snippet.publishedAt, RFC3339.date(from: "2024-05-29T10:28:10Z"))
        XCTAssertEqual(live.snippet.actualStartTime?.timeIntervalSince1970 ?? 0, 1716980407.123, accuracy: 0.001)

        let ready = page.items[1]
        XCTAssertTrue(ready.isUpcoming)
        XCTAssertEqual(ready.snippet.scheduledStartTime, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(ready.contentDetails?.latencyPreference, .ultraLow)
        XCTAssertNil(ready.snippet.actualStartTime)

        // Unknown enum values must not fail decoding.
        let future = page.items[2]
        XCTAssertEqual(future.lifeCycleStatus, .unknown)
        XCTAssertEqual(future.status?.privacyStatus, .private)
        XCTAssertNil(future.contentDetails)
    }

    // MARK: Request shape

    func testListRequestCarriesAuthAndQuery() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        let client = makeClient(transport)

        _ = try await client.broadcasts(.upcoming, pageToken: "NEXT")

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.path, "/youtube/v3/liveBroadcasts")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer t0k3n")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Ios-Bundle-Identifier"), "com.example.app")
        let query = request.queryItems
        XCTAssertEqual(query["part"], "id,snippet,contentDetails,status")
        XCTAssertEqual(query["broadcastStatus"], "upcoming")
        XCTAssertEqual(query["maxResults"], "50")
        XCTAssertEqual(query["pageToken"], "NEXT")
        XCTAssertEqual(query["key"], "API-KEY")
    }

    func testAllBroadcastsFollowsPagesAndSortsNewestFirst() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list")          // has nextPageToken
        await transport.enqueue(body: Data(#"{"kind":"k","etag":"e","items":[]}"#.utf8)) // last page
        let client = makeClient(transport)

        let all = try await client.allBroadcasts()

        XCTAssertEqual(all.map(\.id), ["ghi789DONE", "abc123LIVE", "def456READY"])
        let requests = await transport.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertNil(requests[0].queryItems["pageToken"])
        XCTAssertEqual(requests[1].queryItems["pageToken"], "CAUQAA")
    }

    func testCreateBroadcastBody() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list") // any broadcast-shaped JSON would do
        let client = makeClient(transport)
        let start = Date(timeIntervalSince1970: 1_800_000_000)

        // The list fixture is not a single broadcast; we only care about the outgoing request here.
        _ = try? await client.createBroadcast(.init(
            title: "Hello",
            description: "World",
            scheduledStartTime: start,
            privacyStatus: .unlisted,
            enableAutoStart: true,
            latencyPreference: .low
        ))

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.queryItems["part"], "id,snippet,contentDetails,status")

        let body = request.jsonBody
        let snippet = try XCTUnwrap(body["snippet"] as? [String: Any])
        XCTAssertEqual(snippet["title"] as? String, "Hello")
        XCTAssertEqual(snippet["description"] as? String, "World")
        XCTAssertEqual(snippet["scheduledStartTime"] as? String, "2027-01-15T08:00:00.000Z")
        XCTAssertNil(snippet["scheduledEndTime"], "nil optionals must be omitted, not sent as null")

        let status = try XCTUnwrap(body["status"] as? [String: Any])
        XCTAssertEqual(status["privacyStatus"] as? String, "unlisted")
        XCTAssertEqual(status["selfDeclaredMadeForKids"] as? Bool, false)

        let details = try XCTUnwrap(body["contentDetails"] as? [String: Any])
        XCTAssertEqual(details["enableAutoStart"] as? Bool, true)
        XCTAssertEqual(details["latencyPreference"] as? String, "low")
        let monitor = try XCTUnwrap(details["monitorStream"] as? [String: Any])
        XCTAssertEqual(monitor["enableMonitorStream"] as? Bool, true)
        XCTAssertNil(monitor["embedHtml"])
    }

    func testUpdateSendsOnlyWritableFields() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        let client = makeClient(transport)
        var broadcast = try await client.broadcasts().items[0]
        broadcast.snippet.title = "Renamed"
        broadcast.status?.privacyStatus = .private

        try await transport.enqueue(fixture: "liveBroadcasts.list")
        _ = try? await client.updateBroadcast(broadcast)

        let last = await transport.requests.last
        let request = try XCTUnwrap(last)
        XCTAssertEqual(request.httpMethod, "PUT")
        let body = request.jsonBody
        XCTAssertEqual(body["id"] as? String, "abc123LIVE")
        XCTAssertNil(body["etag"])
        XCTAssertNil(body["kind"])
        XCTAssertEqual((body["snippet"] as? [String: Any])?["title"] as? String, "Renamed")
        XCTAssertNil((body["snippet"] as? [String: Any])?["publishedAt"], "read-only field must not be echoed")
        XCTAssertEqual((body["status"] as? [String: Any])?["privacyStatus"] as? String, "private")
        XCTAssertNil((body["status"] as? [String: Any])?["lifeCycleStatus"])
        XCTAssertNil((body["contentDetails"] as? [String: Any])?["boundStreamId"])
    }

    func testTransitionAndBindQueries() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        let client = makeClient(transport)

        _ = try? await client.transition(broadcastID: "B1", to: .live)
        _ = try? await client.bind(broadcastID: "B1", streamID: "S1")

        let requests = await transport.requests
        XCTAssertEqual(requests[0].url?.path, "/youtube/v3/liveBroadcasts/transition")
        XCTAssertEqual(requests[0].queryItems["broadcastStatus"], "live")
        XCTAssertEqual(requests[0].queryItems["id"], "B1")
        XCTAssertEqual(requests[1].url?.path, "/youtube/v3/liveBroadcasts/bind")
        XCTAssertEqual(requests[1].queryItems["streamId"], "S1")
    }

    func testDeleteBroadcastsAttemptsAllAndReportsFirstFailure() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 204, body: Data())
        try await transport.enqueue(status: 403, fixture: "error.403")
        await transport.enqueue(status: 204, body: Data())
        let client = makeClient(transport)

        do {
            try await client.deleteBroadcasts(ids: ["a", "b", "c"])
            XCTFail("expected an error")
        } catch let error as YouTubeLiveError {
            XCTAssertEqual(error.statusCode, 403)
        }
        let requests = await transport.requests
        XCTAssertEqual(requests.count, 3, "all deletions must be attempted even if one fails")
        XCTAssertTrue(requests.allSatisfy { $0.httpMethod == "DELETE" })
    }
}
