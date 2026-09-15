import Foundation

/// A `liveChatMessage` resource.
///
/// Docs: https://developers.google.com/youtube/v3/live/docs/liveChatMessages
public struct LiveChatMessage: Codable, Sendable, Equatable, Identifiable {
    public let kind: String
    public let etag: String
    public let id: String
    public let snippet: Snippet
    /// Present when the `authorDetails` part was requested (the default in this library).
    public let authorDetails: AuthorDetails?

    public struct Snippet: Codable, Sendable, Equatable {
        public let type: MessageType
        public let liveChatId: String
        public let authorChannelId: String?
        public let publishedAt: Date
        public let hasDisplayContent: Bool?
        /// Ready-to-show text for any message type (text, Super Chat, membership, …).
        public let displayMessage: String?
        public let textMessageDetails: TextMessageDetails?
        public let superChatDetails: SuperChatDetails?
        public let superStickerDetails: SuperStickerDetails?
        public let messageDeletedDetails: MessageDeletedDetails?
        public let userBannedDetails: UserBannedDetails?
    }

    public enum MessageType: String, Sendable, CaseIterable, LenientCodableEnum {
        case textMessageEvent, superChatEvent, superStickerEvent, newSponsorEvent, memberMilestoneChatEvent
        case membershipGiftingEvent, giftMembershipReceivedEvent, messageDeletedEvent, messageRetractedEvent
        case userBannedEvent, chatEndedEvent, sponsorOnlyModeStartedEvent, sponsorOnlyModeEndedEvent, tombstone
        case unknown
        public static var fallback: MessageType { .unknown }
    }

    public struct TextMessageDetails: Codable, Sendable, Equatable {
        public let messageText: String
    }

    public struct SuperChatDetails: Codable, Sendable, Equatable {
        /// Micros of `currency`, serialised as a string by Google.
        public let amountMicros: String?
        public let currency: String?
        public let amountDisplayString: String?
        public let userComment: String?
        public let tier: Int?
    }

    public struct SuperStickerDetails: Codable, Sendable, Equatable {
        public let amountMicros: String?
        public let currency: String?
        public let amountDisplayString: String?
        public let tier: Int?
    }

    public struct MessageDeletedDetails: Codable, Sendable, Equatable {
        public let deletedMessageId: String?
    }

    public struct UserBannedDetails: Codable, Sendable, Equatable {
        public let banType: String?
        public let banDurationSeconds: String?
    }

    public struct AuthorDetails: Codable, Sendable, Equatable {
        public let channelId: String
        public let channelUrl: String?
        public let displayName: String
        public let profileImageUrl: String?
        public let isVerified: Bool?
        public let isChatOwner: Bool?
        public let isChatSponsor: Bool?
        public let isChatModerator: Bool?
    }
}

public extension LiveChatMessage {
    /// The text to show in a chat UI: `displayMessage`, falling back to the raw text message.
    var text: String { snippet.displayMessage ?? snippet.textMessageDetails?.messageText ?? "" }
    var authorName: String { authorDetails?.displayName ?? snippet.authorChannelId ?? "" }
}

/// Response body of `liveChatMessages.list`.
public struct LiveChatMessageListModel: Codable, Sendable, Equatable {
    public let kind: String
    public let etag: String
    public let nextPageToken: String?
    /// How long YouTube asks clients to wait before polling again.
    public let pollingIntervalMillis: Int?
    /// Set once the chat has ended (broadcast complete).
    public let offlineAt: Date?
    public let pageInfo: LiveBroadcastListModel.PageInfo?
    public let items: [LiveChatMessage]
}

/// Wire format of `liveChatMessages.insert`.
struct InsertChatMessageBody: Encodable {
    struct Snippet: Encodable {
        let liveChatId: String
        let type = "textMessageEvent"
        let textMessageDetails: LiveChatMessage.TextMessageDetails
    }
    let snippet: Snippet
}
