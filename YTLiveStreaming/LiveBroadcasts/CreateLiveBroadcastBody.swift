//
//  CreateLiveBroadcastBody.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//
import Foundation

// MARK: - Insert LiveBroadcasts. Request Body

/**
  Insert liveBroadcast. Request Body
  Request
   POST https://www.googleapis.com/youtube/v3/liveBroadcasts
  Scope
   https://www.googleapis.com/auth/youtube
   https://www.googleapis.com/auth/youtube.force-ssl
  Responce
   If successful, this method returns a liveBroadcast resource in the response body.
 @param
 @return
 **/
struct CreateLiveBroadcastBody: Codable {
    struct Status: Codable {
        var privacyStatus: String
        var selfDeclaredMadeForKids: Bool
    }

    struct Snipped: Codable {
        var title: String
        var description: String
        var scheduledStartTime: String
        var scheduledEndTime: String

        init(title: String, description: String, scheduledStartTime: Date, scheduledEndTime: Date) {
            self.title = title
            self.description = description
            self.scheduledStartTime = scheduledStartTime.toJSONformat()
            self.scheduledEndTime = scheduledEndTime.toJSONformat()
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
    
    init(body: PostLiveBroadcastBody) {
        snippet = Snipped(title: body.title, description: body.description, scheduledStartTime: body.scheduledStartTime, scheduledEndTime: body.scheduledEndTime)
        status = Status(privacyStatus: body.privacyStatus, selfDeclaredMadeForKids: body.selfDeclaredMadeForKids)
        contentDetails = ContentDetails(enableAutoStart: body.enableAutoStart,
                                        enableAutoStop: body.enableAutoStop,
                                        enableClosedCaptions: body.enableClosedCaptions,
                                        enableDvr: body.enableDvr,
                                        enableEmbed: body.enableEmbed,
                                        recordFromStart: body.recordFromStart,
                                        enableMonitorStream: body.enableMonitorStream,
                                        broadcastStreamDelayMs: body.broadcastStreamDelayMs)
    }
}
