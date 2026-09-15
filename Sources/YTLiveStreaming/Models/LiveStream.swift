import Foundation

/// A `liveStream` resource: the video pipe (RTMP/DASH/HLS ingest) that a broadcast is bound to.
///
/// Docs: https://developers.google.com/youtube/v3/live/docs/liveStreams
public struct LiveStreamModel: Codable, Sendable, Equatable, Identifiable {
    /// Always `youtube#liveStream`.
    public let kind: String
    public let etag: String
    public let id: String
    public var snippet: Snippet?
    public var cdn: CDN?
    public let status: Status?
    public var contentDetails: ContentDetails?

    public struct Snippet: Codable, Sendable, Equatable {
        public let publishedAt: Date?
        public let channelId: String?
        public var title: String
        public var description: String?
        public let isDefaultStream: Bool?
    }

    public struct CDN: Codable, Sendable, Equatable {
        public var ingestionType: IngestionType?
        public let ingestionInfo: IngestionInfo?
        public var resolution: StreamResolution?
        public var frameRate: FrameRate?
        /// Deprecated by YouTube in favour of `resolution` + `frameRate`; still returned.
        public let format: String?
    }

    /// What an encoder needs to push video to YouTube.
    public struct IngestionInfo: Codable, Sendable, Equatable {
        /// The stream key. Combine with `ingestionAddress` as `ingestionAddress/streamName`.
        public let streamName: String
        public let ingestionAddress: String
        public let backupIngestionAddress: String?
        public let rtmpsIngestionAddress: String?
        public let rtmpsBackupIngestionAddress: String?

        /// `rtmp://…/live2/<streamName>` — the full URL most encoders accept as a single field.
        public var fullIngestionURL: String { "\(ingestionAddress)/\(streamName)" }
    }

    public struct Status: Codable, Sendable, Equatable {
        public let streamStatus: StreamStatus
        public let healthStatus: HealthStatus?
    }

    public struct HealthStatus: Codable, Sendable, Equatable {
        public let status: StreamHealth
        /// Unix time in seconds. Google serialises 64-bit integers as strings.
        public let lastUpdateTimeSeconds: String?
        public let configurationIssues: [ConfigurationIssue]?
    }

    public struct ConfigurationIssue: Codable, Sendable, Equatable {
        public let type: String?
        public let severity: String?
        public let reason: String?
        public let description: String?
    }

    public struct ContentDetails: Codable, Sendable, Equatable {
        public let closedCaptionsIngestionUrl: String?
        /// Whether the stream can be bound to several broadcasts over time.
        public var isReusable: Bool?
    }
}

public extension LiveStreamModel {
    var streamStatus: StreamStatus { status?.streamStatus ?? .unknown }
    var health: StreamHealth { status?.healthStatus?.status ?? .unknown }
    /// `true` once YouTube is receiving data on this stream.
    var isReceivingData: Bool { streamStatus == .active }
}

/// Response body of `liveStreams.list`.
public struct LiveStreamListModel: Codable, Sendable, Equatable {
    public let kind: String
    public let etag: String
    public let nextPageToken: String?
    public let prevPageToken: String?
    public let pageInfo: LiveBroadcastListModel.PageInfo?
    public let items: [LiveStreamModel]
}

// MARK: - Request bodies

/// Parameters for `liveStreams.insert`.
public struct CreateStreamRequest: Sendable, Equatable {
    public var title: String
    public var description: String
    public var ingestionType: IngestionType
    public var resolution: StreamResolution
    public var frameRate: FrameRate
    public var isReusable: Bool

    public init(
        title: String,
        description: String = "",
        ingestionType: IngestionType = .rtmp,
        resolution: StreamResolution = .variable,
        frameRate: FrameRate = .variable,
        isReusable: Bool = true
    ) {
        self.title = title
        self.description = description
        self.ingestionType = ingestionType
        self.resolution = resolution
        self.frameRate = frameRate
        self.isReusable = isReusable
    }
}

struct InsertStreamBody: Encodable {
    struct Snippet: Encodable {
        let title: String
        let description: String
    }
    struct CDN: Encodable {
        let ingestionType: IngestionType
        let resolution: StreamResolution
        let frameRate: FrameRate
    }
    struct ContentDetails: Encodable {
        let isReusable: Bool
    }

    let snippet: Snippet
    let cdn: CDN
    let contentDetails: ContentDetails

    init(_ request: CreateStreamRequest) {
        snippet = Snippet(title: request.title, description: request.description)
        cdn = CDN(ingestionType: request.ingestionType, resolution: request.resolution, frameRate: request.frameRate)
        contentDetails = ContentDetails(isReusable: request.isReusable)
    }
}

/// Wire format of `liveStreams.update`. `cdn` is only writable while the stream is inactive.
struct UpdateStreamBody: Encodable {
    struct Snippet: Encodable {
        let title: String
        let description: String?
    }
    struct CDN: Encodable {
        let ingestionType: IngestionType?
        let resolution: StreamResolution?
        let frameRate: FrameRate?
    }
    struct ContentDetails: Encodable {
        let isReusable: Bool?
    }

    let id: String
    let snippet: Snippet?
    let cdn: CDN?
    let contentDetails: ContentDetails?

    init(_ stream: LiveStreamModel) {
        id = stream.id
        snippet = stream.snippet.map { Snippet(title: $0.title, description: $0.description) }
        cdn = stream.cdn.map { CDN(ingestionType: $0.ingestionType, resolution: $0.resolution, frameRate: $0.frameRate) }
        contentDetails = stream.contentDetails.map { ContentDetails(isReusable: $0.isReusable) }
    }
}
