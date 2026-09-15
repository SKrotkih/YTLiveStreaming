import Foundation
import XCTest
@testable import YTLiveStreaming

final class StreamTests: XCTestCase {

    func testStreamDecodesIngestionInfo() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveStreams.list")
        let client = makeClient(transport)

        let stream = try await client.stream(id: "stream-1")

        XCTAssertEqual(stream.id, "stream-1")
        XCTAssertEqual(stream.cdn?.ingestionType, .rtmp)
        XCTAssertEqual(stream.cdn?.resolution, .variable)
        XCTAssertEqual(stream.cdn?.frameRate, .variable)
        XCTAssertEqual(stream.cdn?.ingestionInfo?.streamName, "abcd-efgh-ijkl-mnop-qrst")
        XCTAssertEqual(stream.cdn?.ingestionInfo?.fullIngestionURL, "rtmp://a.rtmp.youtube.com/live2/abcd-efgh-ijkl-mnop-qrst")
        XCTAssertEqual(stream.cdn?.ingestionInfo?.rtmpsIngestionAddress, "rtmps://a.rtmps.youtube.com/live2")
        XCTAssertTrue(stream.isReceivingData)
        XCTAssertEqual(stream.health, .good)
        XCTAssertEqual(stream.status?.healthStatus?.lastUpdateTimeSeconds, "1716980400")
        XCTAssertEqual(stream.contentDetails?.isReusable, true)

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.queryItems["part"], "id,snippet,cdn,status,contentDetails")
        XCTAssertEqual(request.queryItems["id"], "stream-1")
    }

    func testStreamNotFoundWhenListIsEmpty() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"{"kind":"k","etag":"e","items":[]}"#.utf8))
        let client = makeClient(transport)

        do {
            _ = try await client.stream(id: "missing")
            XCTFail("expected notFound")
        } catch YouTubeLiveError.notFound {
            // ok
        }
    }

    func testCreateStreamBody() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveStreams.list") // wrong shape on purpose; request is what we check
        let client = makeClient(transport)

        _ = try? await client.createStream(.init(title: "Cam 1", resolution: .p1080, frameRate: .fps60, isReusable: false))

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/youtube/v3/liveStreams")
        let body = request.jsonBody
        XCTAssertEqual((body["snippet"] as? [String: Any])?["title"] as? String, "Cam 1")
        let cdn = try XCTUnwrap(body["cdn"] as? [String: Any])
        XCTAssertEqual(cdn["ingestionType"] as? String, "rtmp")
        XCTAssertEqual(cdn["resolution"] as? String, "1080p")
        XCTAssertEqual(cdn["frameRate"] as? String, "60fps")
        XCTAssertEqual((body["contentDetails"] as? [String: Any])?["isReusable"] as? Bool, false)
    }

    func testCreateBroadcastWithStreamChainsInsertInsertBind() async throws {
        let transport = MockTransport()
        let broadcastJSON = try JSONSerialization.data(withJSONObject: singleBroadcast)
        await transport.enqueue(body: broadcastJSON)                         // liveBroadcasts.insert
        let streamsList = try JSONSerialization.jsonObject(with: try Fixtures.data("liveStreams.list")) as! [String: Any]
        let streamJSON = try JSONSerialization.data(withJSONObject: (streamsList["items"] as! [Any])[0])
        await transport.enqueue(body: streamJSON)                            // liveStreams.insert
        await transport.enqueue(body: broadcastJSON)                         // liveBroadcasts.bind
        let client = makeClient(transport)

        let (broadcast, stream) = try await client.createBroadcastWithStream(
            .init(title: "Chained", scheduledStartTime: Date(timeIntervalSince1970: 1_800_000_000)),
            stream: .init(title: "Encoder")
        )

        XCTAssertEqual(broadcast.id, "new-broadcast")
        XCTAssertEqual(stream.id, "stream-1")
        let requests = await transport.requests
        XCTAssertEqual(requests.map { $0.url?.path }, [
            "/youtube/v3/liveBroadcasts", "/youtube/v3/liveStreams", "/youtube/v3/liveBroadcasts/bind"
        ])
        XCTAssertEqual(requests[2].queryItems["id"], "new-broadcast")
        XCTAssertEqual(requests[2].queryItems["streamId"], "stream-1")
    }

    private var singleBroadcast: [String: Any] {
        [
            "kind": "youtube#liveBroadcast",
            "etag": "e",
            "id": "new-broadcast",
            "snippet": [
                "publishedAt": "2024-06-01T00:00:00Z",
                "channelId": "UC1",
                "title": "Chained",
                "description": "",
                "scheduledStartTime": "2027-01-15T08:00:00.000Z"
            ],
            "status": ["lifeCycleStatus": "created", "privacyStatus": "public"]
        ]
    }
}

final class ErrorAndAuthTests: XCTestCase {

    func testGoogleErrorPayloadIsMapped() async throws {
        let transport = MockTransport()
        try await transport.enqueue(status: 403, fixture: "error.403")
        let client = makeClient(transport)

        do {
            _ = try await client.transition(broadcastID: "B1", to: .live)
            XCTFail("expected forbidden")
        } catch let error as YouTubeLiveError {
            guard case .forbidden(let api) = error else { return XCTFail("got \(error)") }
            XCTAssertEqual(api?.code, 403)
            XCTAssertEqual(api?.message, "Stream is inactive")
            XCTAssertEqual(api?.reason, "errorStreamInactive")
            XCTAssertEqual(error.statusCode, 403)
            XCTAssertTrue(error.errorDescription?.contains("Stream is inactive") == true)
        }
    }

    func testNonGoogleBodyBecomesHTTPError() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 502, body: Data("<html>bad gateway</html>".utf8))
        let client = makeClient(transport)

        do {
            _ = try await client.broadcasts()
            XCTFail("expected http error")
        } catch YouTubeLiveError.http(let code, let body) {
            XCTAssertEqual(code, 502)
            XCTAssertEqual(String(decoding: body, as: UTF8.self), "<html>bad gateway</html>")
        }
    }

    func testDecodingFailureKeepsBody() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"{"kind":"youtube#liveBroadcastListResponse"}"#.utf8)) // no etag/items
        let client = makeClient(transport)

        do {
            _ = try await client.broadcasts()
            XCTFail("expected decoding error")
        } catch YouTubeLiveError.decoding(_, let body) {
            XCTAssertFalse(body.isEmpty)
        }
    }

    func testUnauthorizedIsRetriedOnceWithRefreshedToken() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 401, body: Data())
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        let provider = CountingTokenProvider(refreshed: "fresh")
        let client = makeClient(transport, tokenProvider: provider)

        let page = try await client.broadcasts()

        XCTAssertEqual(page.items.count, 3)
        let requests = await transport.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests[0].value(forHTTPHeaderField: "Authorization"), "Bearer token-1")
        XCTAssertEqual(requests[1].value(forHTTPHeaderField: "Authorization"), "Bearer fresh")
        let refreshCalls = await provider.refreshCalls
        XCTAssertEqual(refreshCalls, 1)
    }

    func testUnauthorizedWithoutRefreshSurfaces401() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 401, body: Data())
        let client = makeClient(transport) // StaticTokenProvider: no refresh

        do {
            _ = try await client.broadcasts()
            XCTFail("expected unauthorized")
        } catch YouTubeLiveError.unauthorized(let api) {
            XCTAssertNil(api)
        }
        let count = await transport.requests.count
        XCTAssertEqual(count, 1)
    }

    func testMissingTokenNeverHitsNetwork() async throws {
        let transport = MockTransport()
        let client = makeClient(transport, tokenProvider: StaticTokenProvider(""))

        do {
            _ = try await client.broadcasts()
            XCTFail("expected missingAccessToken")
        } catch YouTubeLiveError.missingAccessToken {
            // ok
        }
        let count = await transport.requests.count
        XCTAssertEqual(count, 0)
    }

    func testAPIKeyAndBundleHeaderAreOptional() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveBroadcasts.list")
        let client = YouTubeLiveClient(
            tokenProvider: StaticTokenProvider("t"),
            configuration: .init(apiKey: nil, bundleIdentifier: nil),
            transport: transport
        )

        _ = try await client.broadcasts()

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertNil(request.queryItems["key"])
        XCTAssertNil(request.value(forHTTPHeaderField: "X-Ios-Bundle-Identifier"))
    }
}
