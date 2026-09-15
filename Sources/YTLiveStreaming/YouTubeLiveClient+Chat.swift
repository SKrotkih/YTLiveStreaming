import Foundation

// MARK: - Live chat

public extension YouTubeLiveClient {
    /// One page of chat messages. `liveChatId` comes from `broadcast.snippet.liveChatId`.
    /// Pass the previous result's `nextPageToken` to get only newer messages, and wait
    /// `pollingIntervalMillis` between calls — or use ``chatMessageStream(liveChatId:)``.
    func chatMessages(liveChatId: String, pageToken: String? = nil, maxResults: Int = 200) async throws -> LiveChatMessageListModel {
        var query = [
            Endpoint.part(Parts.chatMessage),
            URLQueryItem(name: "liveChatId", value: liveChatId),
            URLQueryItem(name: "maxResults", value: String(min(max(maxResults, 200), 2000)))
        ]
        if let pageToken {
            query.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        return try await perform(Endpoint(method: .get, path: "liveChat/messages", query: query))
    }

    /// A live feed of chat messages: each element is the batch of messages that arrived since
    /// the previous one. Polls at the interval YouTube requests (`pollingIntervalMillis`) and
    /// finishes when the chat goes offline or the consuming task is cancelled.
    ///
    /// ```swift
    /// for try await batch in youtube.chatMessageStream(liveChatId: id) {
    ///     messages.append(contentsOf: batch)
    /// }
    /// ```
    func chatMessageStream(liveChatId: String) -> AsyncThrowingStream<[LiveChatMessage], any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var pageToken: String?
                do {
                    while !Task.isCancelled {
                        let page = try await self.chatMessages(liveChatId: liveChatId, pageToken: pageToken)
                        if !page.items.isEmpty {
                            continuation.yield(page.items)
                        }
                        if page.offlineAt != nil {
                            break
                        }
                        pageToken = page.nextPageToken
                        let millis = max(page.pollingIntervalMillis ?? 5000, 500)
                        try await Task.sleep(nanoseconds: UInt64(millis) * 1_000_000)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// `liveChatMessages.insert`: posts a text message as the signed-in channel.
    @discardableResult
    func sendChatMessage(_ text: String, liveChatId: String) async throws -> LiveChatMessage {
        let body = InsertChatMessageBody(snippet: .init(
            liveChatId: liveChatId,
            textMessageDetails: .init(messageText: text)
        ))
        return try await perform(Endpoint(
            method: .post,
            path: "liveChat/messages",
            query: [Endpoint.part("snippet")],
            body: try JSONCoding.encode(body)
        ))
    }

    /// `liveChatMessages.delete`: removes a message (owner/moderator only).
    func deleteChatMessage(id: String) async throws {
        try await performNoContent(Endpoint(
            method: .delete,
            path: "liveChat/messages",
            query: [URLQueryItem(name: "id", value: id)]
        ))
    }
}

// MARK: - Cuepoints and thumbnails

public extension YouTubeLiveClient {
    /// `liveBroadcasts.cuepoint`: inserts an ad break into a live broadcast.
    @discardableResult
    func insertCuepoint(broadcastID: String, _ request: CuepointRequest = CuepointRequest()) async throws -> Cuepoint {
        try await perform(Endpoint(
            method: .post,
            path: "liveBroadcasts/cuepoint",
            query: [URLQueryItem(name: "id", value: broadcastID)],
            body: try JSONCoding.encode(InsertCuepointBody(request))
        ))
    }

    /// `thumbnails.set`: uploads a custom thumbnail (JPEG/PNG/GIF, ≤ 2 MB) for the broadcast's video.
    /// The broadcast ID is the video ID.
    @discardableResult
    func setThumbnail(broadcastID: String, imageData: Data, contentType: String = "image/jpeg") async throws -> ThumbnailSetResponse {
        try await perform(Endpoint(
            method: .post,
            path: "thumbnails/set",
            query: [
                URLQueryItem(name: "videoId", value: broadcastID),
                URLQueryItem(name: "uploadType", value: "media")
            ],
            body: imageData,
            contentType: contentType,
            baseURLOverride: YouTubeHosts.upload
        ))
    }
}

/// Response body of `thumbnails.set`.
public struct ThumbnailSetResponse: Codable, Sendable, Equatable {
    public let kind: String
    public let etag: String?
    public let items: [LiveBroadcastStreamModel.Thumbnails]
}
