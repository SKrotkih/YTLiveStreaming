import Foundation

/// A YouTube channel (`channels` resource), as returned by ``YouTubeLiveClient/myChannel()``.
public struct ChannelModel: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let snippet: Snippet?
    public let status: Status?

    public struct Snippet: Codable, Sendable, Equatable {
        public let title: String
        public let description: String?
        /// The channel's handle, e.g. `"@mychannel"`, when it has one.
        public let customUrl: String?
        public let thumbnails: LiveBroadcastStreamModel.Thumbnails?
    }

    public struct Status: Codable, Sendable, Equatable {
        /// `"public"`, `"unlisted"` or `"private"`.
        public let privacyStatus: String?
        /// Whether the channel is linked to a YouTube user or Google+ account (`false` for
        /// some legacy channels, which then cannot stream).
        public let isLinked: Bool?
        /// `"allowed"`, `"eligible"`, `"disallowed"` — long uploads need a verified channel,
        /// the same verification custom thumbnails need.
        public let longUploadsStatus: String?
        public let madeForKids: Bool?
    }
}

struct ChannelListModel: Decodable {
    let items: [ChannelModel]?
}
