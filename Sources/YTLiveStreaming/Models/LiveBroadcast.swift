import Foundation

/// A `liveBroadcast` resource: an event that will be (or was) streamed live on YouTube.
///
/// Docs: https://developers.google.com/youtube/v3/live/docs/liveBroadcasts
///
/// Fields that YouTube documents as optional, or that only appear for some `part`s or in
/// some lifecycle states, are optional here so decoding never fails on a partial resource.
public struct LiveBroadcastStreamModel: Codable, Sendable, Equatable, Identifiable {
    /// Always `youtube#liveBroadcast`.
    public let kind: String
    public let etag: String
    /// The ID YouTube assigns to the broadcast. It is also the video ID.
    public let id: String
    public var snippet: Snippet
    public var contentDetails: ContentDetails?
    public var status: Status?

    public struct Snippet: Codable, Sendable, Equatable {
        /// When the broadcast was added to YouTube's schedule.
        public let publishedAt: Date
        public let channelId: String
        public var title: String
        public var description: String
        public let thumbnails: Thumbnails?
        /// For broadcasts created without a start time this is Unix epoch zero.
        public var scheduledStartTime: Date?
        public var scheduledEndTime: Date?
        /// Only present once the broadcast is (or was) live.
        public let actualStartTime: Date?
        /// Only present once the broadcast is complete.
        public let actualEndTime: Date?
        public let isDefaultBroadcast: Bool?
        /// ID for the broadcast's live chat, usable with the `liveChatMessages` resource.
        public let liveChatId: String?
    }

    public struct Thumbnails: Codable, Sendable, Equatable {
        public let defaultThumbnail: Thumbnail?
        public let medium: Thumbnail?
        public let high: Thumbnail?
        public let standard: Thumbnail?
        public let maxres: Thumbnail?

        enum CodingKeys: String, CodingKey {
            case defaultThumbnail = "default"
            case medium, high, standard, maxres
        }

        /// The largest thumbnail available.
        public var best: Thumbnail? { maxres ?? standard ?? high ?? medium ?? defaultThumbnail }
    }

    public struct Thumbnail: Codable, Sendable, Equatable {
        public let url: String
        public let width: Int?
        public let height: Int?
    }

    public struct ContentDetails: Codable, Sendable, Equatable {
        /// The `liveStream` bound to this broadcast, if any.
        public let boundStreamId: String?
        public let boundStreamLastUpdateTimeMs: Date?
        public var monitorStream: MonitorStream?
        public var enableEmbed: Bool?
        public var enableDvr: Bool?
        public var recordFromStart: Bool?
        public var enableClosedCaptions: Bool?
        public var closedCaptionsType: String?
        public var projection: String?
        public var enableLowLatency: Bool?
        public var latencyPreference: LatencyPreference?
        public var enableAutoStart: Bool?
        public var enableAutoStop: Bool?
    }

    public struct MonitorStream: Codable, Sendable, Equatable {
        public var enableMonitorStream: Bool?
        public var broadcastStreamDelayMs: Int?
        public let embedHtml: String?

        public init(enableMonitorStream: Bool? = nil, broadcastStreamDelayMs: Int? = nil) {
            self.enableMonitorStream = enableMonitorStream
            self.broadcastStreamDelayMs = broadcastStreamDelayMs
            self.embedHtml = nil
        }
    }

    public struct Status: Codable, Sendable, Equatable {
        public let lifeCycleStatus: LifeCycleStatus
        public var privacyStatus: PrivacyStatus
        public let recordingStatus: String?
        public let madeForKids: Bool?
        public var selfDeclaredMadeForKids: Bool?
    }
}

public extension LiveBroadcastStreamModel {
    /// `status.lifeCycleStatus`, or `.unknown` when the `status` part was not requested.
    var lifeCycleStatus: LifeCycleStatus { status?.lifeCycleStatus ?? .unknown }

    var isLive: Bool { lifeCycleStatus == .live || lifeCycleStatus == .liveStarting }
    var isUpcoming: Bool { lifeCycleStatus == .ready || lifeCycleStatus == .created }
    var isCompleted: Bool { lifeCycleStatus == .complete }

    /// The public watch URL for this broadcast.
    var watchURL: URL? { URL(string: "https://www.youtube.com/watch?v=\(id)") }
}

/// Response body of `liveBroadcasts.list`.
public struct LiveBroadcastListModel: Codable, Sendable, Equatable {
    public let kind: String
    public let etag: String
    public let nextPageToken: String?
    public let prevPageToken: String?
    public let pageInfo: PageInfo?
    public let items: [LiveBroadcastStreamModel]

    public struct PageInfo: Codable, Sendable, Equatable {
        public let totalResults: Int?
        public let resultsPerPage: Int?
    }
}

// MARK: - Request bodies

/// Parameters for `liveBroadcasts.insert`.
///
/// Only `title` and `scheduledStartTime` are required by YouTube; everything else has the
/// same defaults the YouTube web UI uses.
public struct CreateBroadcastRequest: Sendable, Equatable {
    public var title: String
    public var description: String
    public var scheduledStartTime: Date
    public var scheduledEndTime: Date?
    public var privacyStatus: PrivacyStatus
    public var selfDeclaredMadeForKids: Bool
    public var enableAutoStart: Bool
    public var enableAutoStop: Bool
    public var enableClosedCaptions: Bool
    public var enableDvr: Bool
    public var enableEmbed: Bool
    public var recordFromStart: Bool
    public var enableMonitorStream: Bool
    public var broadcastStreamDelayMs: Int
    public var latencyPreference: LatencyPreference?

    public init(
        title: String,
        description: String = "",
        scheduledStartTime: Date,
        scheduledEndTime: Date? = nil,
        privacyStatus: PrivacyStatus = .public,
        selfDeclaredMadeForKids: Bool = false,
        enableAutoStart: Bool = false,
        enableAutoStop: Bool = false,
        enableClosedCaptions: Bool = false,
        enableDvr: Bool = true,
        enableEmbed: Bool = true,
        recordFromStart: Bool = true,
        enableMonitorStream: Bool = true,
        broadcastStreamDelayMs: Int = 0,
        latencyPreference: LatencyPreference? = nil
    ) {
        self.title = title
        self.description = description
        self.scheduledStartTime = scheduledStartTime
        self.scheduledEndTime = scheduledEndTime
        self.privacyStatus = privacyStatus
        self.selfDeclaredMadeForKids = selfDeclaredMadeForKids
        self.enableAutoStart = enableAutoStart
        self.enableAutoStop = enableAutoStop
        self.enableClosedCaptions = enableClosedCaptions
        self.enableDvr = enableDvr
        self.enableEmbed = enableEmbed
        self.recordFromStart = recordFromStart
        self.enableMonitorStream = enableMonitorStream
        self.broadcastStreamDelayMs = broadcastStreamDelayMs
        self.latencyPreference = latencyPreference
    }
}

/// Wire format of `liveBroadcasts.insert`.
struct InsertBroadcastBody: Encodable {
    struct Snippet: Encodable {
        let title: String
        let description: String
        let scheduledStartTime: Date
        let scheduledEndTime: Date?
    }
    struct Status: Encodable {
        let privacyStatus: PrivacyStatus
        let selfDeclaredMadeForKids: Bool
    }
    struct ContentDetails: Encodable {
        let monitorStream: LiveBroadcastStreamModel.MonitorStream
        let enableAutoStart: Bool
        let enableAutoStop: Bool
        let enableClosedCaptions: Bool
        let enableDvr: Bool
        let enableEmbed: Bool
        let recordFromStart: Bool
        let latencyPreference: LatencyPreference?
    }

    let snippet: Snippet
    let status: Status
    let contentDetails: ContentDetails

    init(_ request: CreateBroadcastRequest) {
        snippet = Snippet(
            title: request.title,
            description: request.description,
            scheduledStartTime: request.scheduledStartTime,
            scheduledEndTime: request.scheduledEndTime
        )
        status = Status(
            privacyStatus: request.privacyStatus,
            selfDeclaredMadeForKids: request.selfDeclaredMadeForKids
        )
        contentDetails = ContentDetails(
            monitorStream: .init(
                enableMonitorStream: request.enableMonitorStream,
                broadcastStreamDelayMs: request.broadcastStreamDelayMs
            ),
            enableAutoStart: request.enableAutoStart,
            enableAutoStop: request.enableAutoStop,
            enableClosedCaptions: request.enableClosedCaptions,
            enableDvr: request.enableDvr,
            enableEmbed: request.enableEmbed,
            recordFromStart: request.recordFromStart,
            latencyPreference: request.latencyPreference
        )
    }
}

/// Wire format of `liveBroadcasts.update`: the resource `id` plus only the writable fields.
/// YouTube rejects the request if read-only fields are included, so we never echo the model back.
struct UpdateBroadcastBody: Encodable {
    struct Snippet: Encodable {
        let title: String
        let description: String
        let scheduledStartTime: Date?
        let scheduledEndTime: Date?
    }
    struct Status: Encodable {
        let privacyStatus: PrivacyStatus
        let selfDeclaredMadeForKids: Bool?
    }
    struct ContentDetails: Encodable {
        let monitorStream: LiveBroadcastStreamModel.MonitorStream?
        let enableAutoStart: Bool?
        let enableAutoStop: Bool?
        let enableClosedCaptions: Bool?
        let enableDvr: Bool?
        let enableEmbed: Bool?
        let recordFromStart: Bool?
        let latencyPreference: LatencyPreference?
    }

    let id: String
    let snippet: Snippet
    let status: Status?
    let contentDetails: ContentDetails?

    init(_ broadcast: LiveBroadcastStreamModel) {
        id = broadcast.id
        snippet = Snippet(
            title: broadcast.snippet.title,
            description: broadcast.snippet.description,
            scheduledStartTime: broadcast.snippet.scheduledStartTime,
            scheduledEndTime: broadcast.snippet.scheduledEndTime
        )
        status = broadcast.status.map {
            Status(privacyStatus: $0.privacyStatus, selfDeclaredMadeForKids: $0.selfDeclaredMadeForKids)
        }
        contentDetails = broadcast.contentDetails.map {
            ContentDetails(
                monitorStream: $0.monitorStream.map {
                    LiveBroadcastStreamModel.MonitorStream(
                        enableMonitorStream: $0.enableMonitorStream,
                        broadcastStreamDelayMs: $0.broadcastStreamDelayMs
                    )
                },
                enableAutoStart: $0.enableAutoStart,
                enableAutoStop: $0.enableAutoStop,
                enableClosedCaptions: $0.enableClosedCaptions,
                enableDvr: $0.enableDvr,
                enableEmbed: $0.enableEmbed,
                recordFromStart: $0.recordFromStart,
                latencyPreference: $0.latencyPreference
            )
        }
    }
}
