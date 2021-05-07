//
//  LiveBroadcastStreamModel.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct LiveBroadcastStreamModel: Codable {
    public let etag: String
    public let id: String
    public let kind: String
    public var snippet: Snippet
    public let contentDetails: ContentDetails?
    public var status: Status?

    public struct Snippet: Codable {
        public let channelId: String
        public let description: String
        public let isDefaultBroadcast: Bool
        private var _publishedAt: String
        private var _scheduledStartTime: String
        public let thumbnails: Thumbnails
        public var title: String
        public let liveChatId: String?

        enum CodingKeys: String, CodingKey {
            case channelId
            case description
            case isDefaultBroadcast
            case _publishedAt = "publishedAt"
            case _scheduledStartTime = "scheduledStartTime"
            case thumbnails
            case title
            case liveChatId
        }

        public var publishedAt: Date {
            return convertJSONtoDate(json: _publishedAt)
        }

        public var scheduledStartTime: Date {
            get {
                return convertJSONtoDate(json: _scheduledStartTime)
            }
            set {
                _scheduledStartTime = newValue.toJSONformat()
            }
        }
    }

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
        public let height: Int
        public let url: String
        public let width: Int
    }

    public struct ContentDetails: Codable {
        public let startWithSlate: Bool
        public let recordFromStart: Bool
        public let closedCaptionsType: String
        public let enableLowLatency: Bool
        public let enableClosedCaptions: Bool
        public let enableContentEncryption: Bool
        public let enableEmbed: Bool
        public let projection: String
        public let enableDvr: Bool
        public let monitorStream: MonitorStream
        public let boundStreamId: String?
    }

    public struct MonitorStream: Codable {
        public let enableMonitorStream: Bool
        public let broadcastStreamDelayMs: Int
        public let embedHtml: String
    }

    public struct Status: Codable {
        public let lifeCycleStatus: String
        public let recordingStatus: String
        public var privacyStatus: String
    }
}
