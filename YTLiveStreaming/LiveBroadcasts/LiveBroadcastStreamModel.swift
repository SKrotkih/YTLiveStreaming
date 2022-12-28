//
//  LiveBroadcastStreamModel.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//

import Foundation
/**
 YouTube -> Live Streaming API Docs
  https://developers.google.com/youtube/v3/live/docs/liveBroadcasts
 liveBroadcast resource represents an event that will be streamed, via live video, on YouTube.
 Note:
  We get it in the items field response of the  GET https://www.googleapis.com/youtube/v3/liveBroadcasts request
 @param
 @return
 **/
public struct LiveBroadcastStreamModel: Codable {
    public let etag: String     // The Etag of this resource.
    public let id: String       // The ID that YouTube assigns to uniquely identify the broadcast.
    public let kind: String     // Identifies the API resource's type. The value will be youtube#liveBroadcast
    public var snippet: Snippet // The snippet object contains basic details about the event, including its title, description, start time, and end time.
    public let contentDetails: ContentDetails?
    public var status: Status?  // The status object contains information about the event's status.

    public struct Snippet: Codable {
        public let channelId: String        // The ID that YouTube uses to uniquely identify the channel that is publishing the broadcast.
        public let description: String      // The broadcast's description. As with the title, you can set this field by modifying the broadcast resource or by setting the description field of the corresponding video resource.
        public let isDefaultBroadcast: Bool // This property will be deprecated on or after September 1, 2020. At that time, YouTube will stop creating a default stream and default broadcast when a channel is enabled for live streaming. Please see the deprecation announcement for more details.
        private var _publishedAt: String    // The date and time that the broadcast was added to YouTube's live broadcast schedule. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
        private var _scheduledStartTime: String? // The date and time that the broadcast is scheduled to start. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. Creator Studio supports the ability to create a broadcast without scheduling a start time. In this case, the broadcast starts whenever the channel owner starts streaming. For these broadcasts, the datetime value corresponds to UNIX time zero, and this value cannot be changed via the API or in Creator Studio.
        private var _scheduledEndTime: String?   // The date and time that the broadcast is scheduled to end. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. If a liveBroadcast resource does not specify a value for this property, then the broadcast is scheduled to continue indefinitely. Similarly, if you do not specify a value for this property, then YouTube treats the broadcast as if it will go on indefinitely.
        private var _actualStartTime: String?    // The date and time that the broadcast actually started. This information is only available once the broadcast's state is live. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
        private var _actualEndTime: String?      // The date and time that the broadcast actually ended. This information is only available once the broadcast's state is complete. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
        public let thumbnails: Thumbnails   // A map of thumbnail images associated with the broadcast. For each nested object in this object, the key is the name of the thumbnail image, and the value is an object that contains other information about the thumbnail.
        public var title: String            // The broadcast's title. Note that the broadcast represents exactly one YouTube video. You can set this field by modifying the broadcast resource or by setting the title field of the corresponding video resource.
        public let liveChatId: String?  // The ID for the broadcast's YouTube live chat. With this ID, you can use the liveChatMessage resource's methods to retrieve, insert, or delete chat messages. You can also add or remove chat moderators, ban users from participating in live chats, or remove existing bans

        enum CodingKeys: String, CodingKey {
            case channelId
            case description
            case isDefaultBroadcast
            case _publishedAt = "publishedAt"
            case _scheduledStartTime = "scheduledStartTime"
            case _scheduledEndTime = "scheduledEndTime"
            case _actualStartTime = "actualStartTime"
            case _actualEndTime = "actualEndTime"
            case thumbnails
            case title
            case liveChatId
        }

        public var publishedAt: Date {
            return convertJSONtoDate(date: _publishedAt) ?? Date()
        }
        
        public var scheduledStartTime: Date? {
            get {
                getDate(for: _scheduledStartTime)
            }
            set {
                _scheduledStartTime = setDate(for: newValue)
            }
        }

        public var scheduledEndTime: Date? {
            get {
                getDate(for: _scheduledEndTime)
            }
            set {
                _scheduledStartTime = setDate(for: newValue)
            }
        }

        public var actualStartTime: Date? {
            get {
                getDate(for: _actualStartTime)
            }
            set {
                _actualStartTime = setDate(for: newValue)
            }
        }

        public var actualEndTime: Date? {
            get {
                getDate(for: _actualEndTime)
            }
            set {
                _actualEndTime = setDate(for: newValue)
            }
        }

        private func getDate(for value: String?) -> Date? {
            guard let value else { return nil }
            return convertJSONtoDate(date: value)
        }

        private func setDate(for value: Date?) -> String? {
            if let value {
                return value.toJSONformat()
            } else {
                return nil
            }
        }
    }
    /**
      Valid key values are:
      - default – The default thumbnail image. The default thumbnail for a video – or a resource that refers to a video, such as a playlist item or search result is 120px wide and 90px tall. The default thumbnail for a channel is 88px wide and 88px tall.
      - medium – A higher resolution version of the thumbnail image. For a video (or a resource that refers to a video), this image is 320px wide and 180px tall. For a channel, this image is 240px wide and 240px tall.
      - high – A high resolution version of the thumbnail image. For a video (or a resource that refers to a video), this image is 480px wide and 360px tall. For a channel, this image is 800px wide and 800px tall.
     @param
     @return
     **/
    public struct Thumbnails: Codable {
        public let def: Thumbnail
        public let height: Thumbnail
        public let medium: Thumbnail

        enum CodingKeys: String, CodingKey {
            case def = "default"
            case height = "high"
            case medium
        }
    }

    public struct Thumbnail: Codable {
        public let height: Int  // The image's height.
        public let url: String  // The image's URL.
        public let width: Int   // The image's width.
    }

    public struct ContentDetails: Codable {
        public let boundStreamId: String?
        public let boundStreamLastUpdateTimeMs: Int
        public let monitorStream: MonitorStream
        public let enableEmbed: Bool
        public let enableDvr: Bool
        public let recordFromStart: Bool
        public let enableClosedCaptions: Bool
        public let closedCaptionsType: String
        public let projection: String
        public let enableLowLatency: Bool
        public let latencyPreference: Bool
        public let enableAutoStart: Bool
        public let enableAutoStop: Bool
    }

    public struct MonitorStream: Codable {
        public let enableMonitorStream: Bool
        public let broadcastStreamDelayMs: Int
        public let embedHtml: String
    }

    public struct Status: Codable {
        public let lifeCycleStatus: String
        public var privacyStatus: String
        public let recordingStatus: String
        public let madeForKids: Bool
        public let selfDeclaredMadeForKids: Bool
    }
}

/// Of the filed lifeCycleStatus values
public enum LifiCycleStatus: String, CaseIterable {
    case complete   // – The broadcast is finished.
    case created    // – The broadcast has incomplete settings, so it is not ready to transition to a live or testing status, but it has been created and is otherwise valid.
    case live       // – The broadcast is active.
    case liveStarting // – The broadcast is in the process of transitioning to live status.
    case ready      // – The broadcast settings are complete and the broadcast can transition to a live or testing status.
    case revoked    // – This broadcast was removed by an admin action.
    case testStarting // – The broadcast is in the process of transitioning to testing status.
    case testing    // – The broadcast is only visible to the partner.
}
/**
 Insert Broadcast  HTTP request  POST https://www.googleapis.com/youtube/v3/liveBroadcasts body
 @param
 @return
 **/
public struct PostLiveBroadcastBody {
    // The broadcast's title. Note that the broadcast represents exactly one YouTube video. You can set this field by modifying the broadcast resource or by setting the title field of the corresponding video resource.
    let title: String               // snippet.title
    // The broadcast's description. As with the title, you can set this field by modifying the broadcast resource or by setting the description field of the corresponding video resource.
    let description: String         // snippet.description
    // The date and time that the broadcast is scheduled to start. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. Creator Studio supports the ability to create a broadcast without scheduling a start time. In this case, the broadcast starts whenever the channel owner starts streaming. For these broadcasts, the datetime value corresponds to UNIX time zero, and this value cannot be changed via the API or in Creator Studio.
    let scheduledStartTime: Date    // snippet.scheduledStartTime
    let scheduledEndTime: Date      // snippet.scheduledEndTime
    let selfDeclaredMadeForKids: Bool // status.selfDeclaredMadeForKids
    let enableAutoStart: Bool       // contentDetails.enableAutoStart
    let enableAutoStop: Bool        // contentDetails.enableAutoStop
    let enableClosedCaptions: Bool  // contentDetails.enableClosedCaptions
    let enableDvr: Bool             // contentDetails.enableDvr
    let enableEmbed: Bool           // contentDetails.enableEmbed
    let recordFromStart: Bool       // contentDetails.recordFromStart
    let enableMonitorStream: Bool   // contentDetails.monitorStream.enableMonitorStream
    let broadcastStreamDelayMs: Int // contentDetails.monitorStream.broadcastStreamDelayMs
    let privacyStatus: String       // status.privacyStatus ("public"
    let isReusable: Bool            // For LiveStream insert used. Indicates whether the stream is reusable, which means that it can be bound to multiple broadcasts. It is common for broadcasters to reuse the same stream for many different broadcasts if those broadcasts occur at different times.

    public init(title: String, scheduledStartTime: Date, description: String, scheduledEndTime: Date, selfDeclaredMadeForKids: Bool, enableAutoStart: Bool, enableAutoStop: Bool, enableClosedCaptions: Bool, enableDvr: Bool, enableEmbed: Bool, recordFromStart: Bool, enableMonitorStream: Bool, broadcastStreamDelayMs: Int, privacyStatus: String, isReusable: Bool) {
        self.title = title
        self.scheduledStartTime = scheduledStartTime
        self.description = description
        self.scheduledEndTime = scheduledEndTime
        self.selfDeclaredMadeForKids = selfDeclaredMadeForKids
        self.enableAutoStart = enableAutoStart
        self.enableAutoStop = enableAutoStop
        self.enableClosedCaptions = enableClosedCaptions
        self.enableDvr = enableDvr
        self.enableEmbed = enableEmbed
        self.recordFromStart = recordFromStart
        self.enableMonitorStream = enableMonitorStream
        self.broadcastStreamDelayMs = broadcastStreamDelayMs
        self.privacyStatus = privacyStatus
        self.isReusable = isReusable
    }
}
