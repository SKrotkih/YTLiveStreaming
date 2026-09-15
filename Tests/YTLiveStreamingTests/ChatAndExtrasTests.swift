import Foundation
import XCTest
@testable import YTLiveStreaming

final class ChatTests: XCTestCase {

    func testListDecodesMessagesAndPollingHints() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveChatMessages.list")
        let client = makeClient(transport)

        let page = try await client.chatMessages(liveChatId: "chat-1", pageToken: "PREV")

        XCTAssertEqual(page.items.count, 2)
        XCTAssertEqual(page.pollingIntervalMillis, 2000)
        XCTAssertEqual(page.nextPageToken, "GKj4kLq2")
        XCTAssertNil(page.offlineAt)

        let text = page.items[0]
        XCTAssertEqual(text.snippet.type, .textMessageEvent)
        XCTAssertEqual(text.text, "hello from the chat")
        XCTAssertEqual(text.authorName, "A Viewer")
        XCTAssertEqual(text.authorDetails?.isChatModerator, false)

        let superChat = page.items[1]
        XCTAssertEqual(superChat.snippet.type, .superChatEvent)
        XCTAssertEqual(superChat.snippet.superChatDetails?.amountDisplayString, "$5.00")
        XCTAssertEqual(superChat.snippet.superChatDetails?.tier, 2)
        XCTAssertNil(superChat.snippet.textMessageDetails)

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.url?.path, "/youtube/v3/liveChat/messages")
        XCTAssertEqual(request.queryItems["part"], "id,snippet,authorDetails")
        XCTAssertEqual(request.queryItems["liveChatId"], "chat-1")
        XCTAssertEqual(request.queryItems["pageToken"], "PREV")
        XCTAssertEqual(request.queryItems["maxResults"], "200")
    }

    func testStreamPagesUntilOffline() async throws {
        let transport = MockTransport()
        try await transport.enqueue(fixture: "liveChatMessages.list")   // 2 messages, next token GKj4kLq2
        await transport.enqueue(body: Data(#"{"kind":"k","etag":"e","items":[],"pollingIntervalMillis":10,"nextPageToken":"T2"}"#.utf8))
        await transport.enqueue(body: Data(#"{"kind":"k","etag":"e","items":[],"offlineAt":"2024-05-29T12:00:00Z"}"#.utf8))
        // Make the first poll interval short so the test stays fast.
        let client = makeClient(transport)

        var batches: [[LiveChatMessage]] = []
        for try await batch in client.chatMessageStream(liveChatId: "chat-1") {
            batches.append(batch)
        }

        XCTAssertEqual(batches.count, 1, "empty pages are not yielded")
        XCTAssertEqual(batches[0].map(\.id), ["msg-1", "msg-2"])
        let requests = await transport.requests
        XCTAssertEqual(requests.count, 3, "stops after the offline page")
        XCTAssertNil(requests[0].queryItems["pageToken"])
        XCTAssertEqual(requests[1].queryItems["pageToken"], "GKj4kLq2")
        XCTAssertEqual(requests[2].queryItems["pageToken"], "T2")
    }

    func testSendMessageBody() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"""
        {"kind":"youtube#liveChatMessage","etag":"e","id":"new-msg",
         "snippet":{"type":"textMessageEvent","liveChatId":"chat-1","publishedAt":"2024-05-29T11:03:00Z",
                    "displayMessage":"hi","textMessageDetails":{"messageText":"hi"}}}
        """#.utf8))
        let client = makeClient(transport)

        let message = try await client.sendChatMessage("hi", liveChatId: "chat-1")

        XCTAssertEqual(message.id, "new-msg")
        XCTAssertNil(message.authorDetails)
        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.queryItems["part"], "snippet")
        let snippet = try XCTUnwrap(request.jsonBody["snippet"] as? [String: Any])
        XCTAssertEqual(snippet["liveChatId"] as? String, "chat-1")
        XCTAssertEqual(snippet["type"] as? String, "textMessageEvent")
        XCTAssertEqual((snippet["textMessageDetails"] as? [String: Any])?["messageText"] as? String, "hi")
    }

    func testDeleteMessage() async throws {
        let transport = MockTransport()
        await transport.enqueue(status: 204, body: Data())
        let client = makeClient(transport)

        try await client.deleteChatMessage(id: "msg-1")

        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertEqual(request.url?.path, "/youtube/v3/liveChat/messages")
        XCTAssertEqual(request.queryItems["id"], "msg-1")
    }
}

final class CuepointAndThumbnailTests: XCTestCase {

    func testCuepointBody() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"{"id":"cp-1","cueType":"cueTypeAd","durationSecs":60,"walltimeMs":"1716980500000"}"#.utf8))
        let client = makeClient(transport)
        let at = Date(timeIntervalSince1970: 1_716_980_500)

        let cuepoint = try await client.insertCuepoint(broadcastID: "B1", CuepointRequest(durationSeconds: 60, walltime: at))

        XCTAssertEqual(cuepoint.id, "cp-1")
        XCTAssertEqual(cuepoint.durationSecs, 60)
        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.url?.path, "/youtube/v3/liveBroadcasts/cuepoint")
        XCTAssertEqual(request.queryItems["id"], "B1")
        XCTAssertEqual(request.jsonBody["cueType"] as? String, "cueTypeAd")
        XCTAssertEqual(request.jsonBody["durationSecs"] as? Int, 60)
        XCTAssertEqual(request.jsonBody["walltimeMs"] as? Int64, 1_716_980_500_000)
        XCTAssertNil(request.jsonBody["insertionOffsetTimeMs"])
    }

    func testThumbnailUploadGoesToUploadHostAsRawMedia() async throws {
        let transport = MockTransport()
        await transport.enqueue(body: Data(#"""
        {"kind":"youtube#thumbnailSetResponse","etag":"e",
         "items":[{"default":{"url":"https://i.ytimg.com/vi/B1/default.jpg","width":120,"height":90}}]}
        """#.utf8))
        let client = makeClient(transport)
        let jpeg = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10])

        let response = try await client.setThumbnail(broadcastID: "B1", imageData: jpeg)

        XCTAssertEqual(response.items.first?.defaultThumbnail?.width, 120)
        let first = await transport.requests.first
        let request = try XCTUnwrap(first)
        XCTAssertEqual(request.url?.host, "www.googleapis.com")
        XCTAssertEqual(request.url?.path, "/upload/youtube/v3/thumbnails/set")
        XCTAssertEqual(request.queryItems["videoId"], "B1")
        XCTAssertEqual(request.queryItems["uploadType"], "media")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer t0k3n")
        XCTAssertEqual(request.httpBody, jpeg)
    }

    func testPublicCodersHandleBothDateForms() throws {
        let decoder = JSONDecoder.youtubeLive()
        let data = Data(#"{"a":"2024-05-29T10:28:10Z","b":"2024-05-29T10:28:10.250Z"}"#.utf8)
        struct Dates: Decodable { let a: Date; let b: Date }
        let dates = try decoder.decode(Dates.self, from: data)
        XCTAssertEqual(dates.a.timeIntervalSince1970, 1_716_978_490, accuracy: 0.001)
        XCTAssertEqual(dates.b.timeIntervalSince1970, 1_716_978_490.25, accuracy: 0.001)

        let encoded = try JSONEncoder.youtubeLive().encode(["d": dates.b])
        XCTAssertEqual(String(decoding: encoded, as: UTF8.self), #"{"d":"2024-05-29T10:28:10.250Z"}"#)
    }
}
