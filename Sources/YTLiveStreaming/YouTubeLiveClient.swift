import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A dependency-free, `async/await` client for the YouTube Live Streaming API
/// (`liveBroadcasts` and `liveStreams` resources of YouTube Data API v3).
///
/// ```swift
/// let client = YouTubeLiveClient(tokenProvider: myProvider)
/// let upcoming = try await client.allBroadcasts(.upcoming)
/// let (broadcast, stream) = try await client.createBroadcastWithStream(
///     .init(title: "My event", scheduledStartTime: .now.addingTimeInterval(3600)),
///     stream: .init(title: "My encoder")
/// )
/// print(stream.cdn?.ingestionInfo?.fullIngestionURL ?? "")
/// ```
///
/// The client is stateless apart from its configuration, so a single instance can be shared
/// across the app and used from any task.
public final class YouTubeLiveClient: Sendable {
    public struct Configuration: Sendable {
        /// `https://www.googleapis.com/youtube/v3` unless you proxy the API.
        public var baseURL: URL
        /// Optional. Requests are authorised by the bearer token; the key is only needed when
        /// your Google Cloud project requires it for quota attribution.
        public var apiKey: String?
        /// Sent as `X-Ios-Bundle-Identifier`. Required when `apiKey` is restricted to iOS apps.
        public var bundleIdentifier: String?
        /// Page size for list calls (YouTube caps it at 50).
        public var pageSize: Int

        public init(
            baseURL: URL = URL(string: "https://www.googleapis.com/youtube/v3")!,
            apiKey: String? = nil,
            bundleIdentifier: String? = Bundle.main.bundleIdentifier,
            pageSize: Int = 50
        ) {
            self.baseURL = baseURL
            self.apiKey = apiKey
            self.bundleIdentifier = bundleIdentifier
            self.pageSize = min(max(pageSize, 1), 50)
        }
    }

    public let configuration: Configuration
    private let tokenProvider: any TokenProvider
    private let transport: any HTTPTransport

    public init(
        tokenProvider: any TokenProvider,
        configuration: Configuration = Configuration(),
        transport: any HTTPTransport = URLSession.shared
    ) {
        self.tokenProvider = tokenProvider
        self.configuration = configuration
        self.transport = transport
    }
}

// MARK: - Broadcasts

public extension YouTubeLiveClient {
    /// One page of the signed-in channel's broadcasts. Pass `nextPageToken` from a previous
    /// result to continue; use ``allBroadcasts(_:)`` to fetch every page.
    func broadcasts(_ filter: BroadcastListFilter = .all, pageToken: String? = nil) async throws -> LiveBroadcastListModel {
        var query = [
            Endpoint.part(Parts.broadcast),
            URLQueryItem(name: "broadcastStatus", value: filter.rawValue),
            URLQueryItem(name: "maxResults", value: String(configuration.pageSize))
        ]
        if let pageToken {
            query.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        return try await perform(Endpoint(method: .get, path: "liveBroadcasts", query: query))
    }

    /// Every broadcast matching `filter`, newest first by `publishedAt`.
    func allBroadcasts(_ filter: BroadcastListFilter = .all) async throws -> [LiveBroadcastStreamModel] {
        var items: [LiveBroadcastStreamModel] = []
        var pageToken: String?
        repeat {
            let page = try await broadcasts(filter, pageToken: pageToken)
            items.append(contentsOf: page.items)
            pageToken = page.nextPageToken
        } while pageToken != nil
        return items.sorted { $0.snippet.publishedAt > $1.snippet.publishedAt }
    }

    /// A single broadcast by ID.
    func broadcast(id: String) async throws -> LiveBroadcastStreamModel {
        let list: LiveBroadcastListModel = try await perform(Endpoint(
            method: .get,
            path: "liveBroadcasts",
            query: [Endpoint.part(Parts.broadcast), URLQueryItem(name: "id", value: id)]
        ))
        guard let broadcast = list.items.first else {
            throw YouTubeLiveError.notFound(GoogleAPIError(code: 404, message: "Broadcast \(id) not found"))
        }
        return broadcast
    }

    /// `liveBroadcasts.insert`. The new broadcast has no stream bound yet; see
    /// ``createBroadcastWithStream(_:stream:)`` for the common one-shot flow.
    func createBroadcast(_ request: CreateBroadcastRequest) async throws -> LiveBroadcastStreamModel {
        try await perform(Endpoint(
            method: .post,
            path: "liveBroadcasts",
            query: [Endpoint.part(Parts.broadcast)],
            body: try JSONCoding.encode(InsertBroadcastBody(request))
        ))
    }

    /// Creates a broadcast, creates a stream, and binds them. Returns both resources; the
    /// stream carries the RTMP URL and key for the encoder.
    func createBroadcastWithStream(
        _ request: CreateBroadcastRequest,
        stream streamRequest: CreateStreamRequest
    ) async throws -> (broadcast: LiveBroadcastStreamModel, stream: LiveStreamModel) {
        let broadcast = try await createBroadcast(request)
        let stream = try await createStream(streamRequest)
        let bound = try await bind(broadcastID: broadcast.id, streamID: stream.id)
        return (bound, stream)
    }

    /// `liveBroadcasts.update`. Only the writable fields of `broadcast` are sent
    /// (title, description, schedule, privacy, made-for-kids flag, content details).
    @discardableResult
    func updateBroadcast(_ broadcast: LiveBroadcastStreamModel) async throws -> LiveBroadcastStreamModel {
        try await perform(Endpoint(
            method: .put,
            path: "liveBroadcasts",
            query: [Endpoint.part(Parts.broadcast)],
            body: try JSONCoding.encode(UpdateBroadcastBody(broadcast))
        ))
    }

    /// `liveBroadcasts.delete`.
    func deleteBroadcast(id: String) async throws {
        try await performNoContent(Endpoint(
            method: .delete,
            path: "liveBroadcasts",
            query: [URLQueryItem(name: "id", value: id)]
        ))
    }

    /// Deletes several broadcasts concurrently. Throws the first failure after all
    /// deletions have been attempted, so one bad ID does not leave the rest untouched.
    func deleteBroadcasts(ids: [String]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for id in ids {
                group.addTask { try await self.deleteBroadcast(id: id) }
            }
            var firstError: (any Error)?
            while let result = await group.nextResult() {
                if case .failure(let error) = result, firstError == nil {
                    firstError = error
                }
            }
            if let firstError { throw firstError }
        }
    }

    /// `liveBroadcasts.bind`: attaches a stream to a broadcast (or detaches, with `streamID: nil`).
    @discardableResult
    func bind(broadcastID: String, streamID: String?) async throws -> LiveBroadcastStreamModel {
        var query = [Endpoint.part(Parts.broadcast), URLQueryItem(name: "id", value: broadcastID)]
        if let streamID {
            query.append(URLQueryItem(name: "streamId", value: streamID))
        }
        return try await perform(Endpoint(method: .post, path: "liveBroadcasts/bind", query: query))
    }

    /// `liveBroadcasts.transition`. Transitioning to `.live` or `.testing` requires the bound
    /// stream to be `.active` (the encoder must already be sending data), otherwise YouTube
    /// answers 403 with reason `errorStreamInactive`.
    @discardableResult
    func transition(broadcastID: String, to status: BroadcastTransition) async throws -> LiveBroadcastStreamModel {
        try await perform(Endpoint(
            method: .post,
            path: "liveBroadcasts/transition",
            query: [
                Endpoint.part(Parts.broadcast),
                URLQueryItem(name: "id", value: broadcastID),
                URLQueryItem(name: "broadcastStatus", value: status.rawValue)
            ]
        ))
    }
}

// MARK: - Streams

public extension YouTubeLiveClient {
    /// A single stream by ID.
    func stream(id: String) async throws -> LiveStreamModel {
        let list: LiveStreamListModel = try await perform(Endpoint(
            method: .get,
            path: "liveStreams",
            query: [Endpoint.part(Parts.stream), URLQueryItem(name: "id", value: id)]
        ))
        guard let stream = list.items.first else {
            throw YouTubeLiveError.notFound(GoogleAPIError(code: 404, message: "Stream \(id) not found"))
        }
        return stream
    }

    /// One page of the signed-in channel's streams.
    func streams(pageToken: String? = nil) async throws -> LiveStreamListModel {
        var query = [
            Endpoint.part(Parts.stream),
            URLQueryItem(name: "mine", value: "true"),
            URLQueryItem(name: "maxResults", value: String(configuration.pageSize))
        ]
        if let pageToken {
            query.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        return try await perform(Endpoint(method: .get, path: "liveStreams", query: query))
    }

    /// `liveStreams.insert`.
    func createStream(_ request: CreateStreamRequest) async throws -> LiveStreamModel {
        try await perform(Endpoint(
            method: .post,
            path: "liveStreams",
            query: [Endpoint.part(Parts.stream)],
            body: try JSONCoding.encode(InsertStreamBody(request))
        ))
    }

    /// `liveStreams.update`.
    @discardableResult
    func updateStream(_ stream: LiveStreamModel) async throws -> LiveStreamModel {
        try await perform(Endpoint(
            method: .put,
            path: "liveStreams",
            query: [Endpoint.part(Parts.stream)],
            body: try JSONCoding.encode(UpdateStreamBody(stream))
        ))
    }

    /// `liveStreams.delete`. A stream bound to a broadcast must be unbound first.
    func deleteStream(id: String) async throws {
        try await performNoContent(Endpoint(
            method: .delete,
            path: "liveStreams",
            query: [URLQueryItem(name: "id", value: id)]
        ))
    }
}

// MARK: - Plumbing

extension YouTubeLiveClient {
    func perform<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await send(endpoint)
        return try JSONCoding.decode(T.self, from: data)
    }

    func performNoContent(_ endpoint: Endpoint) async throws {
        _ = try await send(endpoint)
    }

    /// Sends the request, retrying once with a refreshed token on 401.
    private func send(_ endpoint: Endpoint) async throws -> Data {
        let token = try await tokenProvider.accessToken()
        let (data, response) = try await transport.send(try request(endpoint, token: token))
        if (200..<300).contains(response.statusCode) {
            return data
        }
        if response.statusCode == 401, let fresh = try await tokenProvider.refreshAccessToken() {
            let (retryData, retryResponse) = try await transport.send(try request(endpoint, token: fresh))
            if (200..<300).contains(retryResponse.statusCode) {
                return retryData
            }
            throw YouTubeLiveError.from(statusCode: retryResponse.statusCode, body: retryData)
        }
        throw YouTubeLiveError.from(statusCode: response.statusCode, body: data)
    }

    private func request(_ endpoint: Endpoint, token: String) throws -> URLRequest {
        try endpoint.urlRequest(
            baseURL: configuration.baseURL,
            apiKey: configuration.apiKey,
            bundleIdentifier: configuration.bundleIdentifier,
            token: token
        )
    }
}
