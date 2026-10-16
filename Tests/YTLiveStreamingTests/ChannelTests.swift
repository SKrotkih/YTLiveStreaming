import Foundation
import XCTest
@testable import YTLiveStreaming

final class ChannelTests: XCTestCase {

    private func errorBody(code: Int, reason: String) -> Data {
        Data(#"{"error":{"code":\#(code),"message":"m","errors":[{"domain":"youtube","reason":"\#(reason)","message":"m"}]}}"#.utf8)
    }

    func testMyChannelDecodesTheChannel() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"""
        {"kind":"youtube#channelListResponse","items":[{"id":"UC123","snippet":{"title":"My channel",
        "customUrl":"@mine","thumbnails":{"default":{"url":"https://yt3.example/a.jpg","width":88,"height":88}}},
        "status":{"privacyStatus":"public","isLinked":true,"longUploadsStatus":"allowed","madeForKids":false}}]}
        """#.utf8))
        let client = makeClient(transport)

        let channel = try await client.myChannel()

        XCTAssertEqual(channel?.id, "UC123")
        XCTAssertEqual(channel?.snippet?.title, "My channel")
        XCTAssertEqual(channel?.snippet?.customUrl, "@mine")
        XCTAssertEqual(channel?.snippet?.thumbnails?.best?.url, "https://yt3.example/a.jpg")
        XCTAssertEqual(channel?.status?.isLinked, true)

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.url?.path, "/youtube/v3/channels")
        XCTAssertEqual(request.queryItems["part"], "id,snippet,status")
        XCTAssertEqual(request.queryItems["mine"], "true")
    }

    func testMyChannelIsNilWhenTheListIsEmpty() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"{"kind":"youtube#channelListResponse","pageInfo":{"totalResults":0}}"#.utf8))
        let channel = try await makeClient(transport).myChannel()
        XCTAssertNil(channel)
    }

    func testMyChannelIsNilOnSignupRequired() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 401, body: errorBody(code: 401, reason: "youtubeSignupRequired"))
        let channel = try await makeClient(transport).myChannel()
        XCTAssertNil(channel)
    }

    func testMyChannelRethrowsOtherErrors() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 403, body: errorBody(code: 403, reason: "quotaExceeded"))
        do {
            _ = try await makeClient(transport).myChannel()
            XCTFail("expected forbidden")
        } catch let error as YouTubeLiveError {
            XCTAssertTrue(error.isQuotaExceeded)
            XCTAssertFalse(error.isSignupRequired)
        }
    }

    func testErrorClassification() {
        func error(_ status: Int, _ reason: String) -> YouTubeLiveError {
            YouTubeLiveError.from(statusCode: status, body: errorBody(code: status, reason: reason))
        }
        XCTAssertTrue(error(401, "youtubeSignupRequired").isSignupRequired)
        XCTAssertTrue(error(403, "liveStreamingNotEnabled").isLiveStreamingNotEnabled)
        XCTAssertTrue(error(403, "quotaExceeded").isQuotaExceeded)
        XCTAssertTrue(error(403, "dailyLimitExceeded").isQuotaExceeded)
        XCTAssertTrue(error(403, "rateLimitExceeded").isRateLimited)
        XCTAssertTrue(error(403, "userRateLimitExceeded").isRateLimited)
        XCTAssertTrue(YouTubeLiveError.http(statusCode: 429, body: Data()).isRateLimited)
        XCTAssertTrue(error(403, "insufficientPermissions").isInsufficientPermissions)
        XCTAssertEqual(error(404, "liveBroadcastNotFound").reason, "liveBroadcastNotFound")
        XCTAssertFalse(YouTubeLiveError.missingAccessToken.isSignupRequired)
        XCTAssertNil(YouTubeLiveError.missingAccessToken.reason)
    }
}
