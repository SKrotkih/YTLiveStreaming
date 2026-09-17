import XCTest
@testable import YTLiveStreaming

final class PurgeTests: XCTestCase {
    // MARK: - Helpers

    private func broadcastList(id: String, status: String, boundStreamId: String? = "stream-1") -> Data {
        let bound = boundStreamId.map { "\"boundStreamId\": \"\($0)\"," } ?? ""
        return Data("""
        {
          "kind": "youtube#liveBroadcastListResponse", "etag": "e",
          "items": [{
            "kind": "youtube#liveBroadcast", "etag": "e", "id": "\(id)",
            "snippet": { "publishedAt": "2024-05-29T10:28:10Z", "channelId": "UC1", "title": "t", "description": "" },
            "status": { "lifeCycleStatus": "\(status)", "privacyStatus": "unlisted" },
            "contentDetails": { \(bound) "enableEmbed": true }
          }]
        }
        """.utf8)
    }

    /// A single `liveBroadcast` resource, as `liveBroadcasts.transition` returns it.
    private func broadcastResource(id: String, status: String) -> Data {
        Data("""
        {
          "kind": "youtube#liveBroadcast", "etag": "e", "id": "\(id)",
          "snippet": { "publishedAt": "2024-05-29T10:28:10Z", "channelId": "UC1", "title": "t", "description": "" },
          "status": { "lifeCycleStatus": "\(status)", "privacyStatus": "unlisted" },
          "contentDetails": { "enableEmbed": true }
        }
        """.utf8)
    }

    private func streamList(id: String, reusable: Bool) -> Data {
        Data("""
        {
          "kind": "youtube#liveStreamListResponse", "etag": "e",
          "items": [{
            "kind": "youtube#liveStream", "etag": "e", "id": "\(id)",
            "snippet": { "publishedAt": "2024-05-29T10:30:00Z", "channelId": "UC1", "title": "s", "description": "" },
            "contentDetails": { "isReusable": \(reusable) }
          }]
        }
        """.utf8)
    }

    private func googleError(code: Int, reason: String) -> Data {
        Data("""
        { "error": { "code": \(code), "message": "\(reason)", "errors": [{ "message": "\(reason)", "domain": "youtube.liveBroadcast", "reason": "\(reason)" }] } }
        """.utf8)
    }

    private func path(_ request: URLRequest) -> String {
        "\(request.httpMethod ?? "?") \(request.url?.path ?? "?")"
    }

    // MARK: - Tests

    func testPurgeScheduledBroadcastDeletesBroadcastAndStream() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: broadcastList(id: "B1", status: "ready"))   // broadcast(id:)
        await transport.enqueue(status: 204, body: Data())                                    // liveBroadcasts.delete
        await transport.enqueue(status: 200, body: streamList(id: "stream-1", reusable: false)) // stream(id:)
        await transport.enqueue(status: 204, body: Data())                                    // liveStreams.delete
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "B1")

        XCTAssertEqual(result, PurgeResult(broadcastID: "B1", endedFirst: false, deletedAsVideo: false, deletedStreamID: "stream-1"))
        let requests = await transport.requests
        XCTAssertEqual(requests.map(path), [
            "GET /youtube/v3/liveBroadcasts",
            "DELETE /youtube/v3/liveBroadcasts",
            "GET /youtube/v3/liveStreams",
            "DELETE /youtube/v3/liveStreams"
        ])
    }

    func testPurgeCompletedBroadcastFallsBackToVideosDelete() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: broadcastList(id: "B2", status: "complete"))
        await transport.enqueue(status: 403, body: googleError(code: 403, reason: "liveBroadcastDeletionNotAllowed"))
        await transport.enqueue(status: 204, body: Data())                                      // videos.delete
        await transport.enqueue(status: 204, body: Data())                                      // liveBroadcasts.delete again (now allowed)
        await transport.enqueue(status: 200, body: streamList(id: "stream-1", reusable: false))
        await transport.enqueue(status: 204, body: Data())
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "B2")

        XCTAssertTrue(result.deletedAsVideo)
        XCTAssertEqual(result.deletedStreamID, "stream-1")
        let requests = await transport.requests
        XCTAssertEqual(requests.map(path), [
            "GET /youtube/v3/liveBroadcasts",
            "DELETE /youtube/v3/liveBroadcasts",
            "DELETE /youtube/v3/videos",
            "DELETE /youtube/v3/liveBroadcasts",   // the leftover `created` broadcast
            "GET /youtube/v3/liveStreams",
            "DELETE /youtube/v3/liveStreams"
        ])
    }

    func testPurgeCompletedBroadcastLeftoverAlreadyGone() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: broadcastList(id: "B2", status: "complete", boundStreamId: nil))
        await transport.enqueue(status: 403, body: googleError(code: 403, reason: "liveBroadcastDeletionNotAllowed"))
        await transport.enqueue(status: 204, body: Data())                                      // videos.delete
        await transport.enqueue(status: 404, body: googleError(code: 404, reason: "liveBroadcastNotFound"))
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "B2")
        XCTAssertTrue(result.deletedAsVideo)
    }

    func testPurgeCompletedBroadcastAlsoRemovesRecordingWhenBroadcastDeleteSucceeds() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: broadcastList(id: "B3", status: "complete", boundStreamId: nil))
        await transport.enqueue(status: 204, body: Data())                                      // liveBroadcasts.delete
        await transport.enqueue(status: 404, body: googleError(code: 404, reason: "videoNotFound")) // videos.delete → gone already
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "B3")

        XCTAssertFalse(result.deletedAsVideo)
        XCTAssertNil(result.deletedStreamID)
        let requests = await transport.requests
        XCTAssertEqual(requests.map(path), [
            "GET /youtube/v3/liveBroadcasts",
            "DELETE /youtube/v3/liveBroadcasts",
            "DELETE /youtube/v3/videos"
        ])
    }

    func testPurgeLiveBroadcastEndsItFirst() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: broadcastList(id: "B4", status: "live", boundStreamId: nil))
        await transport.enqueue(status: 200, body: broadcastResource(id: "B4", status: "complete"))      // transition
        await transport.enqueue(status: 204, body: Data())                                      // liveBroadcasts.delete
        await transport.enqueue(status: 204, body: Data())                                      // videos.delete
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "B4")

        XCTAssertTrue(result.endedFirst)
        let requests = await transport.requests
        XCTAssertEqual(requests[1].url?.path, "/youtube/v3/liveBroadcasts/transition")
        XCTAssertEqual(requests[1].queryItems["broadcastStatus"], "complete")
    }

    func testPurgeKeepsReusableStream() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: broadcastList(id: "B5", status: "ready"))
        await transport.enqueue(status: 204, body: Data())
        await transport.enqueue(status: 200, body: streamList(id: "stream-1", reusable: true))
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "B5")

        XCTAssertNil(result.deletedStreamID)
        let requests = await transport.requests
        XCTAssertEqual(requests.count, 3, "a reusable stream must not be deleted")
    }

    func testPurgeMissingBroadcastIsNotAnError() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 200, body: Data("{ \"kind\": \"youtube#liveBroadcastListResponse\", \"etag\": \"e\", \"items\": [] }".utf8))
        let client = makeClient(transport)

        let result = try await client.purgeBroadcast(id: "gone")

        XCTAssertEqual(result, PurgeResult(broadcastID: "gone", endedFirst: false, deletedAsVideo: false, deletedStreamID: nil))
    }
}
