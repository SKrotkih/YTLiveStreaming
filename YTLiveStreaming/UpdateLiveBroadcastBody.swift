//
//  UpdateLiveBroadcastBody.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//
import Foundation

// MARK: - Update LiveBroadcasts. Request Body

/// Update LiveBroadcasts. Request Body
/// Request
///  PUT https://www.googleapis.com/youtube/v3/liveBroadcasts
/// Scope
///  https://www.googleapis.com/auth/youtube
///  https://www.googleapis.com/auth/youtube.force-ssl
///
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
        var enableAutoStart:  Bool
        var enableAutoStop:  Bool
        var enableClosedCaptions: Bool
        var enableDvr: Bool
        var enableEmbed: Bool
        var recordFromStart: Bool
        
        init(contentDetails: LiveBroadcastStreamModel.ContentDetails) {
            monitorStream = MonitorStream(enableMonitorStream: contentDetails.monitorStream.enableMonitorStream,
                                          broadcastStreamDelayMs: contentDetails.monitorStream.broadcastStreamDelayMs)
            enableAutoStart = contentDetails.enableAutoStart
            enableAutoStop = contentDetails.enableAutoStop
            enableClosedCaptions = contentDetails.enableClosedCaptions
            enableDvr = contentDetails.enableDvr
            enableEmbed = contentDetails.enableEmbed
            recordFromStart = contentDetails.recordFromStart
        }
    }

    struct Snipped: Codable {
        var title: String
        var description: String
        var scheduledStartTime: String
        var scheduledEndTime: String
        var status: Status?
        var contentDetails: ContentDetails?

        init(broadcast: LiveBroadcastStreamModel) {
            title = broadcast.snippet.title
            description = broadcast.snippet.description
            scheduledStartTime = broadcast.snippet.scheduledStartTime.toJSONformat()
            scheduledEndTime = broadcast.snippet.scheduledEndTime.toJSONformat()
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

// MARK: - Insert LiveBroadcasts. Request Body

/// Insert liveBroadcast. Request Body
/// Request
///  POST https://www.googleapis.com/youtube/v3/liveBroadcasts
/// Scope
///  https://www.googleapis.com/auth/youtube
///  https://www.googleapis.com/auth/youtube.force-ssl
/// Responce
///  If successful, this method returns a liveBroadcast resource in the response body.
struct CreateLiveBroadcastBody: Codable {
    struct Status: Codable {
        var privacyStatus: String
        var selfDeclaredMadeForKids: String
    }

    struct Snipped: Codable {
        var title: String
        var description: String
        var scheduledStartTime: String
        var scheduledEndTime: String

        init(title: String, description: String, startDateTime: Date, endDateTime: Date) {
            self.title = title
            self.description = description
            scheduledStartTime = startDateTime.toJSONformat()
            scheduledEndTime = endDateTime.toJSONformat()
        }
    }

    public struct MonitorStream: Codable {
        public let enableMonitorStream: Bool
        public let broadcastStreamDelayMs: Int
    }
    
    struct ContentDetails: Codable {
        var monitorStream: MonitorStream
        var enableAutoStart: Bool
        var enableAutoStop: Bool
        var enableClosedCaptions: Bool
        var enableDvr: Bool
        var enableEmbed: Bool
        var recordFromStart: Bool
        
        init(enableAutoStart: Bool,
             enableAutoStop: Bool,
             enableClosedCaptions: Bool,
             enableDvr: Bool,
             enableEmbed: Bool,
             recordFromStart: Bool,
             enableMonitorStream: Bool,
             broadcastStreamDelayMs: Int) {
            self.enableAutoStart = enableAutoStart
            self.enableAutoStop = enableAutoStop
            self.enableClosedCaptions = enableClosedCaptions
            self.enableDvr = enableDvr
            self.enableEmbed = enableEmbed
            self.recordFromStart = recordFromStart
            monitorStream = MonitorStream(enableMonitorStream: enableMonitorStream, broadcastStreamDelayMs: broadcastStreamDelayMs)
        }
    }

    let snippet: Snipped
    let status: Status
    let contentDetails: ContentDetails

    init(title: String,
         description: String,
         startDateTime: Date,
         endDateTime: Date,
         selfDeclaredMadeForKids: String,
         enableAutoStart: Bool,
         enableAutoStop: Bool,
         enableClosedCaptions: Bool,
         enableDvr: Bool,
         enableEmbed: Bool,
         recordFromStart: Bool,
         enableMonitorStream: Bool,
         broadcastStreamDelayMs: Int) {
        
        snippet = Snipped(title: title, description: description, startDateTime: startDateTime, endDateTime: endDateTime)
        status = Status(privacyStatus: "public", selfDeclaredMadeForKids: selfDeclaredMadeForKids)
        contentDetails = ContentDetails(enableAutoStart: enableAutoStart,
                                        enableAutoStop: enableAutoStop,
                                        enableClosedCaptions: enableClosedCaptions,
                                        enableDvr: enableDvr,
                                        enableEmbed: enableEmbed,
                                        recordFromStart: recordFromStart,
                                        enableMonitorStream: enableMonitorStream,
                                        broadcastStreamDelayMs: broadcastStreamDelayMs)
    }
}

// MARK: - Insert LiveStreams. Request Body

/// Insert liveStream. Request Body
/// Request
///  POST https://www.googleapis.com/youtube/v3/liveStreams
/// Scope
///  https://www.googleapis.com/auth/youtube
///  https://www.googleapis.com/auth/youtube.force-ssl
///  Data
/// CreateLiveStreamBody codable structure
struct CreateLiveStreamBody: Codable {

    struct Snipped: Codable {
        var title: String
        var description: String

        init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    struct ContentDetails: Codable {
        let isReusable: Bool
    }

    struct Cdn: Codable {
        var frameRate: String
        var ingestionType: String
        var resolution: String

        init(streamName: String) {
            frameRate = LiveAPI.FrameRate
            ingestionType = LiveAPI.IngestionType
            resolution = LiveAPI.Resolution
        }
    }

    let snippet: Snipped
    let cdn: Cdn
    let contentDetails: ContentDetails
    
    init(title: String, description: String, streamName: String, isReusable: Bool) {
        snippet = Snipped(title: title, description: description)
        cdn = Cdn(streamName: streamName)
        contentDetails = ContentDetails(isReusable: isReusable)
    }
}

// MARK: - Update LiveStreams. Request Body

/// Update liveStream. Request Body
/// Request
///   PUT https://www.googleapis.com/youtube/v3/liveStreams
/// Scope
///  https://www.googleapis.com/auth/youtube
///  https://www.googleapis.com/auth/youtube.force-ssl
///
struct UpdateLiveStreamBody: Codable {
    struct Snipped: Codable {
        var title: String
        var description: String

        init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    struct Cdn: Codable {
        let frameRate: String
        let ingestionType: String
        let resolution: String
    }

    let id: String
    let snippet: Snipped
    let cdn: Cdn

    init(id: String, title: String, description: String, frameRate: String, ingestionType: String, resolution: String) {
        self.id = id
        snippet = Snipped(title: title, description: description)
        cdn = Cdn(frameRate: frameRate, ingestionType: ingestionType, resolution: resolution)
    }
}
