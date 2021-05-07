//
//  UpdateLiveBroadcastBody.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UpdateLiveBroadcastBody: Codable {
    struct Status: Codable {
        var privacyStatus: String
    }

    struct MonitorStream: Codable {
        var enableMonitorStream: Bool
        var broadcastStreamDelayMs: Int
    }

    struct ContentDetails: Codable {
        var monitorStream: MonitorStream
        var enableDvr: Bool
        var enableContentEncryption: Bool
        var enableEmbed: Bool
        var recordFromStart: Bool
        var startWithSlate: Bool

        init(contentDetails: LiveBroadcastStreamModel.ContentDetails) {
            monitorStream = MonitorStream(enableMonitorStream: contentDetails.monitorStream.enableMonitorStream,
                                          broadcastStreamDelayMs: contentDetails.monitorStream.broadcastStreamDelayMs)
            enableDvr = contentDetails.enableDvr
            enableContentEncryption = contentDetails.enableContentEncryption
            enableEmbed = contentDetails.enableEmbed
            recordFromStart = contentDetails.recordFromStart
            startWithSlate = contentDetails.startWithSlate
        }
    }

    struct Snipped: Codable {
        var title: String
        var scheduledStartTime: String
        var status: Status?
        var contentDetails: ContentDetails?

        init(broadcast: LiveBroadcastStreamModel) {
            title = broadcast.snippet.title
            scheduledStartTime = broadcast.snippet.scheduledStartTime.toJSONformat()
            if let broadcastStatus = broadcast.status {
                status = Status(privacyStatus: broadcastStatus.privacyStatus)
            }
            if let broadcastContentDetails = broadcast.contentDetails {
                contentDetails = ContentDetails(contentDetails: broadcastContentDetails)
            }
        }
    }

    let id: String
    let snippet: Snipped

    init(broadcast: LiveBroadcastStreamModel) {
        id = broadcast.id
        snippet = Snipped(broadcast: broadcast)
    }
}

struct CreateLiveBroadcastBody: Codable {
    struct Status: Codable {
        var privacyStatus: String
    }

    struct Snipped: Codable {
        var title: String
        var scheduledStartTime: String
        var status: Status

        init(title: String, startDateTime: Date) {
            self.title = title
            scheduledStartTime = startDateTime.toJSONformat()
            status = Status(privacyStatus: "public")
        }
    }

    let snippet: Snipped

    init(title: String, startDateTime: Date) {
        snippet = Snipped(title: title, startDateTime: startDateTime)
    }
}

//   {
//   "snippet": {
//   "title": "My First Live Video",
//   "description": "Description live video"
//   },
//   "cdn": {
//   "format": "1080p",
//   "ingestionType": "rtmp",
//   "ingestionInfo": {
//   "streamName": "stream name 1"
//   }
//   }
//   }
struct CreateLiveStreamBody: Codable {

    struct Snipped: Codable {
        var title: String
        var description: String

        init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    struct IngestionInfo: Codable {
        let streamName: String
    }

    struct Cdn: Codable {
        var resolution: String
        var frameRate: String
        var ingestionType: String
        var ingestionInfo: IngestionInfo

        init(streamName: String) {
            resolution = LiveAPI.Resolution
            frameRate = LiveAPI.FrameRate
            ingestionType = LiveAPI.IngestionType
            ingestionInfo = IngestionInfo(streamName: streamName)
        }
    }

    let snippet: Snipped
    let cdn: Cdn

    init(title: String, description: String, streamName: String) {
        snippet = Snipped(title: title, description: description)
        cdn = Cdn(streamName: streamName)
    }
}

struct UpdateLiveStreamBody: Codable {
    struct Snipped: Codable {
        var title: String

        init(title: String) {
            self.title = title
        }
    }

    struct Cdn: Codable {
        let format: String
        let ingestionType: String
    }

    let id: String
    let snippet: Snipped
    let cdn: Cdn

    init(id: String, title: String, format: String, ingestionType: String) {
        self.id = id
        snippet = Snipped(title: title)
        cdn = Cdn(format: format, ingestionType: ingestionType)
    }
}
