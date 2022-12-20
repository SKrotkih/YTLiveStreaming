//
//  LiveStreamModel.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//
import Foundation
import SwiftyJSON

public protocol Deserializable {
  static func decode(_ json: JSON) -> Self
}
/**
 liveStreams resource.
 Docs:
  https://developers.google.com/youtube/v3/live/docs/liveStreams
 Note
  it is the items filed of response GET https://www.googleapis.com/youtube/v3/liveStreams request
 @param
 @return
 **/
public struct LiveStreamModel {
    // The snippet object contains basic details about the stream, including its channel, title, and description.
    public struct Snipped {
        // The date and time that the stream was created.
        // The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
        public let publishedAt: String
        // The ID that YouTube uses to uniquely identify the channel that is transmitting the stream.
        public let channelId: String
        // The stream's title. The value must be between 1 and 128 characters long.
        public let title: String
        // The stream's description. The value cannot be longer than 10000 characters.
        public let description: String
        // Indicates whether this stream is the default stream for the channel.
        public let isDefaultStream: Bool
    }

    public struct IngestionInfo {
        public let streamName: String
        public let ingestionAddress: String  // cdn.ingestionInfo.ingestionAddress	string
        // The primary ingestion URL that you should use to stream video to YouTube.
        // You must stream video to this URL.
        // Depending on which application or tool you use to encode your
        // video stream, you may need to enter the stream URL and stream
        // name separately or you may need to concatenate them in the
        // following format:  STREAM_URL/STREAM_NAME
        public let backupIngestionAddress: String
    }

    // The cdn object defines the live stream's content delivery network (CDN) settings.
    // These settings provide details about the manner in which you stream your content to YouTube.
    public struct CDN {
        public let ingestionType: String     // The method or protocol used to transmit the video stream. (dash or rtmp)
        // The ingestionInfo object contains information that YouTube provides
        // that you need to transmit your stream to YouTube.
        public let ingestionInfo: IngestionInfo
        public let resolution: String     // The resolution of the inbound video data.
        public let frameRate: String      // The frame rate of the inbound video data.
    }

    public struct Status {
        public let streamStatus: String // Valid values for this property are:
        //      active – The stream is in active state which means the user is receiving data via the stream.
        //      created – The stream has been created but does not have valid CDN settings.
        //      error – An error condition exists on the stream.
        //      inactive – The stream is in inactive state which means the user is not receiving data via the stream.
        //      ready – The stream has valid CDN settings.
        public let healthStatus: HealthStatus   // This object contains information about the
                                                // live stream's health status, which could be used to identify,
                                                // diagnose, and resolve streaming problems.
    }

    public struct HealthStatus {
        public let status: String
        public let lastUpdateTimeSeconds: Int
        public let configurationIssues: [ConfigurationIssues]
    }

    public struct ConfigurationIssues {
        public let type: String
        public let severity: String
        public let reason: String
        public let description: String
    }

    public struct ContentDetails {
        public let closedCaptionsIngestionUrl: String
        public let isReusable: Bool
    }
    
    public let kind: String        // Identifies the API resource's type. The value will be youtube#liveStream.
    public let etag: String        // The Etag of this resource.
    public let id: String          // The ID that YouTube assigns to uniquely identify the stream.
    public let snipped: Snipped
    public let cdn: CDN
    public let status: Status
    public let contentDetails: ContentDetails
}

// MARK: - Decode to LiveStreamModel

extension LiveStreamModel: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel {
        let snippet = LiveStreamModel.Snipped.decode(json["snippet"])
        let cdn = LiveStreamModel.CDN.decode(json["cdn"])
        let status = LiveStreamModel.Status.decode(json["status"])
        let contentDetails = LiveStreamModel.ContentDetails.decode(json["contentDetails"])
        
        let model = LiveStreamModel(
            kind: json["kind"].stringValue,
            etag: json["etag"].stringValue,
            id: json["id"].stringValue,
            snipped: snippet,
            cdn: cdn,
            status: status,
            contentDetails: contentDetails
        )
        return model
    }
}

extension LiveStreamModel.Snipped: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.Snipped {
        let model = LiveStreamModel.Snipped(
            publishedAt: json["publishedAt"].stringValue,
            channelId: json["channelId"].stringValue,
            title: json["title"].stringValue,
            description: json["description"].stringValue,
            isDefaultStream: json["isDefaultStream"].boolValue
        )
        return model
    }
}

extension LiveStreamModel.CDN: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.CDN {
        let ingestionInfo = LiveStreamModel.IngestionInfo.decode(json["ingestionInfo"])
        let model = LiveStreamModel.CDN(
            ingestionType: json["ingestionType"].stringValue,
            ingestionInfo: ingestionInfo,
            resolution: json["resolution"].stringValue,
            frameRate: json["frameRate"].stringValue
        )
        return model
    }
}

extension LiveStreamModel.IngestionInfo: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.IngestionInfo {
        let model = LiveStreamModel.IngestionInfo(
            streamName: json["streamName"].stringValue,
            ingestionAddress: json["ingestionAddress"].stringValue,
            backupIngestionAddress: json["backupIngestionAddress"].stringValue
        )
        return model
    }
}

extension LiveStreamModel.Status: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.Status {
        let healthStatus = LiveStreamModel.HealthStatus.decode(json["healthStatus"])
        let model = LiveStreamModel.Status(
            streamStatus: json["streamStatus"].stringValue,
            healthStatus: healthStatus
        )
        return model
    }
}

extension LiveStreamModel.HealthStatus: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.HealthStatus {
        let configurationIssues: [LiveStreamModel.ConfigurationIssues] = []
        let model = LiveStreamModel.HealthStatus(
            status: json["status"].stringValue,
            lastUpdateTimeSeconds: json["lastUpdateTimeSeconds"].intValue,
            configurationIssues: configurationIssues
        )
        return model
    }
}

extension LiveStreamModel.ConfigurationIssues: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.ConfigurationIssues {
        let model = LiveStreamModel.ConfigurationIssues(
            type: json["type"].stringValue,
            severity: json["severity"].stringValue,
            reason: json["reason"].stringValue,
            description: json["description"].stringValue
        )
        return model
    }
}

extension LiveStreamModel.ContentDetails: Deserializable {
    public static func decode(_ json: JSON) -> LiveStreamModel.ContentDetails {
        let model = LiveStreamModel.ContentDetails(
            closedCaptionsIngestionUrl: json["closedCaptionsIngestionUrl"].stringValue,
            isReusable: json["isReusable"].boolValue
        )
        return model
    }
}
