//
//  UpdateLiveBroadcastBody.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//

import Foundation

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
        var enableAutoStop: Bool

        init(contentDetails: LiveBroadcastStreamModel.ContentDetails) {
            monitorStream = MonitorStream(enableMonitorStream: contentDetails.monitorStream.enableMonitorStream,
                                          broadcastStreamDelayMs: contentDetails.monitorStream.broadcastStreamDelayMs)
            enableDvr = contentDetails.enableDvr
            enableContentEncryption = contentDetails.enableContentEncryption
            enableEmbed = contentDetails.enableEmbed
            recordFromStart = contentDetails.recordFromStart
            startWithSlate = contentDetails.startWithSlate
            enableAutoStop = contentDetails.enableAutoStop ?? false
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
        var selfDeclaredMadeForKids: Bool
    }

    struct Snipped: Codable {
        var title: String
        var description: String
        var scheduledStartTime: String

        init(title: String, description: String, startDateTime: Date) {
            self.title = title
            self.description = description
            scheduledStartTime = startDateTime.toJSONformat()
        }
    }
    
    struct ContentDetails: Codable {
        var enableAutoStop: Bool
        var enableEmbed: Bool
    }

    let snippet: Snipped
    let status: Status
    let contentDetails: ContentDetails

    init(title: String, description: String, startDateTime: Date, privacy: String? = nil, enableAutoStop: Bool? = nil, enableEmbed: Bool? = nil) {
        snippet = Snipped(title: title, description: description, startDateTime: startDateTime)
        status = Status(privacyStatus: privacy ?? "public", selfDeclaredMadeForKids: false)
        contentDetails = ContentDetails(enableAutoStop: enableAutoStop ?? false, enableEmbed: enableEmbed ?? false)
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
