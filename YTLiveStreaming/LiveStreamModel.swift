//
//  LiveStreamModel.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

//                        {
//
//                           "kind": "youtube#liveStream",
//                           "etag": "\"I_8xdZu766_FSaexEaDXTIfEWc0/trdCzFsxkNp91WcZP8dcOA9tjMU\"",
//                           "id": "m4xprzPvVL8Uravaneq7CA1476422506176336",
//                           "snippet": {
//                              "publishedAt": "2016-10-14T05:21:46.000Z",
//                              "channelId": "UCm4xprzPvVL8Uravaneq7CA",
//                              "title": "My First Live Video",
//                              "description": "Description live video",
//                              "isDefaultStream": false
//                           },
//                           "cdn": {
//                              "format": "1080p",
//                              "ingestionType": "rtmp",
//                              "ingestionInfo": {
//                                 "streamName": "m4r0-xg07-9x0q-4dpk",
//                                 "ingestionAddress": "rtmp://a.rtmp.youtube.com/live2",
//                                 "backupIngestionAddress": "rtmp://b.rtmp.youtube.com/live2?backup=1"
//                              },
//                              "resolution": "1080p",
//                              "frameRate": "30fps"
//                           },
//                           "status": {
//                              "streamStatus": "ready",
//                              "healthStatus": {
//                                 "status": "noData"
//                              }
//                           }
//                        }

public struct LiveStreamModel {

// The snippet object contains basic details about the stream, including its channel, title, and description.
   
   public struct Snipped {
      public let publishedAt: String    // The date and time that the stream was created. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
      public let channelId: String      // The ID that YouTube uses to uniquely identify the channel that is transmitting the stream.
      public let title: String          // The stream's title. The value must be between 1 and 128 characters long.
      public let description: String    // The stream's description. The value cannot be longer than 10000 characters.
      public let isDefaultStream: Bool  // Indicates whether this stream is the default stream for the channel. ()
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

// The cdn object defines the live stream's content delivery network (CDN) settings. These settings provide details about the manner in which you stream your content to YouTube.
   
   public struct CDN {
      public let format: String  // This property has been deprecated as of April 18, 2016. Instead, please use the cdn.frameRate and cdn.resolution properties to specify the frame rate and resolution separately.
      public let ingestionType: String     // The method or protocol used to transmit the video stream. (dash or rtmp)
      public let ingestionInfo: IngestionInfo    // The ingestionInfo object contains information that YouTube provides that you need to transmit your stream to YouTube.
      public let resolution: String     // The resolution of the inbound video data.
      public let frameRate: String      // The frame rate of the inbound video data.
   }

   public struct HealthStatus {
      public let status: String
   }
   
   public struct Status {
      public let streamStatus: String // Valid values for this property are:
//      active – The stream is in active state which means the user is receiving data via the stream.
//      created – The stream has been created but does not have valid CDN settings.
//      error – An error condition exists on the stream.
//      inactive – The stream is in inactive state which means the user is not receiving data via the stream.
//      ready – The stream has valid CDN settings.
      public let healthStatus: HealthStatus   // This object contains information about the live stream's health status, which could be used to identify, diagnose, and resolve streaming problems.
   }
   
   public let kind: String        // Identifies the API resource's type. The value will be youtube#liveStream.
   public let etag: String        // The Etag of this resource.
   public let id: String          // The ID that YouTube assigns to uniquely identify the stream.
   public let snipped: Snipped
   public let cdn: CDN
   public let status: Status
}

// MARK: - Decodable

extension LiveStreamModel: Decodable {
   public static func decode(_ json: JSON) -> LiveStreamModel {
      
      let snippet = LiveStreamModel.Snipped.decode(json["snippet"])
      let cdn = LiveStreamModel.CDN.decode(json["cdn"])
      let status = LiveStreamModel.Status.decode(json["status"])
      
      let model = LiveStreamModel(
      kind: json["kind"].stringValue,
      etag: json["etag"].stringValue,
      id: json["id"].stringValue,
      snipped: snippet,
      cdn: cdn,
      status: status
      )
      return model
   }
}

extension LiveStreamModel.Snipped {
   public static func decode(_ json: JSON) -> LiveStreamModel.Snipped {
      let model = LiveStreamModel.Snipped (
         publishedAt: json["publishedAt"].stringValue,
         channelId: json["channelId"].stringValue,
         title: json["title"].stringValue,
         description: json["description"].stringValue,
         isDefaultStream: json["isDefaultStream"].boolValue
      )
      return model
   }
}

extension LiveStreamModel.CDN {
   public static func decode(_ json: JSON) -> LiveStreamModel.CDN {
      let ingestionInfo = LiveStreamModel.IngestionInfo.decode(json["ingestionInfo"])
      let model = LiveStreamModel.CDN (
         format: json["format"].stringValue,
         ingestionType: json["ingestionType"].stringValue,
         ingestionInfo: ingestionInfo,
         resolution: json["resolution"].stringValue,
         frameRate: json["frameRate"].stringValue
      )
      return model
   }
}

extension LiveStreamModel.IngestionInfo {
   public static func decode(_ json: JSON) -> LiveStreamModel.IngestionInfo {
      let model = LiveStreamModel.IngestionInfo (
         streamName: json["streamName"].stringValue,
         ingestionAddress: json["ingestionAddress"].stringValue,
         backupIngestionAddress: json["backupIngestionAddress"].stringValue
      )
      return model
   }
}

extension LiveStreamModel.Status {
   public static func decode(_ json: JSON) -> LiveStreamModel.Status {
      let healthStatus = LiveStreamModel.HealthStatus.decode(json["healthStatus"])
      let model = LiveStreamModel.Status (
         streamStatus: json["streamStatus"].stringValue,
         healthStatus: healthStatus
      )
      return model
   }
}

extension LiveStreamModel.HealthStatus {
   public static func decode(_ json: JSON) -> LiveStreamModel.HealthStatus {
      let model = LiveStreamModel.HealthStatus (
         status: json["status"].stringValue
      )
      return model
   }
}
