//
//  LiveBroadcastStreamModel.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

//{
//   "snippet" : {
//      "description" : "",
//      "thumbnails" : {
//         "high" : {
//            "url" : "https:\/\/i.ytimg.com\/vi\/sGCYiZ-ycK8\/hqdefault_live.jpg",
//            "width" : 480,
//            "height" : 360
//         },
//         "default" : {
//            "url" : "https:\/\/i.ytimg.com\/vi\/sGCYiZ-ycK8\/default_live.jpg",
//            "width" : 120,
//            "height" : 90
//         },
//         "medium" : {
//            "url" : "https:\/\/i.ytimg.com\/vi\/sGCYiZ-ycK8\/mqdefault_live.jpg",
//            "width" : 320,
//            "height" : 180
//         }
//      },
//      "liveChatId" : "Cg0KC3NHQ1lpWi15Y0s4",
//      "scheduledStartTime" : "2016-10-15T18:09:46.000Z",
//      "publishedAt" : "2016-10-15T18:04:47.000Z",
//      "isDefaultBroadcast" : false,
//      "channelId" : "UCm4xprzPvVL8Uravaneq7CA",
//      "title" : "Broadcast"
//   },
//   "etag" : "\"I_8xdZu766_FSaexEaDXTIfEWc0\/CxHg2duuuY-cSug1zylA1NwtqtI\"",
//   "id" : "sGCYiZ-ycK8",
//   "status" : {
//      "lifeCycleStatus" : "created",
//      "recordingStatus" : "notRecording",
//      "privacyStatus" : "public"
//   },
//   "contentDetails" : {
//      "startWithSlate" : false,
//      "recordFromStart" : true,
//      "closedCaptionsType" : "closedCaptionsDisabled",
//      "enableLowLatency" : false,
//      "enableClosedCaptions" : false,
//      "enableContentEncryption" : false,
//      "enableEmbed" : true,
//      "projection" : "rectangular",
//      "enableDvr" : true,
//      "monitorStream" : {
//         "enableMonitorStream" : true,
//         "broadcastStreamDelayMs" : 0,
//         "embedHtml" : "<iframe width=\"425\" height=\"344\" src=\"https:\/\/www.youtube.com\/embed\/sGCYiZ-ycK8?autoplay=1&livemonitor=1\" frameborder=\"0\" allowfullscreen><\/iframe>"
//      }
//   },
//   "kind" : "youtube#liveBroadcast"
//}

public struct LiveBroadcastStreamModel {

   public struct Snipped {
      public let publishedAt: Date
      public let channelId: String
      public var title: String
      public let description: String
      public let isDefaultBroadcast: Bool
      public let liveChatId: String
      public var scheduledStartTime: Date
      public let thumbnails: Thumbnails
   }

   public struct Thumbnail {
      public let height: Int
      public let url: String
      public let width: Int
   }
   
   public struct Thumbnails {
      public let def: Thumbnail
      public let height: Thumbnail
      public let medium: Thumbnail
   }
   
   public struct ContentDetails {
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
      public let boundStreamId: String
   }
   
   public struct MonitorStream {
      public let enableMonitorStream: Bool
      public let broadcastStreamDelayMs: Int
      public let embedHtml: String
   }

   public struct Status {
      public let lifeCycleStatus: String
      public let recordingStatus: String
      public var privacyStatus: String
   }
   
   public let kind: String
   public let etag: String
   public let id: String
   public var snipped: Snipped
   public let contentDetails: ContentDetails
   public var status: Status
}

// MARK: - Decodable

extension LiveBroadcastStreamModel: Decodable {
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel {
      
      let snipped = LiveBroadcastStreamModel.Snipped.decode(json["snippet"])
      let contentDetails = LiveBroadcastStreamModel.ContentDetails.decode(json["contentDetails"])
      let status = LiveBroadcastStreamModel.Status.decode(json["status"])
      
      let model = LiveBroadcastStreamModel(
      kind: json["kind"].stringValue,
      etag: json["etag"].stringValue,
      id: json["id"].stringValue,
      snipped: snipped,
      contentDetails: contentDetails,
      status: status
      )
      return model
   }
}

extension LiveBroadcastStreamModel.Snipped {
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel.Snipped {
      
      let thumbnails = LiveBroadcastStreamModel.Thumbnails.decode(json["thumbnails"])
      
      let model = LiveBroadcastStreamModel.Snipped (
         publishedAt: convertJSONtoDate(json: json["publishedAt"].stringValue),
         channelId: json["channelId"].stringValue,
         title: json["title"].stringValue,
         description: json["description"].stringValue,
         isDefaultBroadcast: json["isDefaultStream"].boolValue,
         liveChatId: json["liveChatId"].stringValue,
         scheduledStartTime: convertJSONtoDate(json: json["scheduledStartTime"].stringValue),
         thumbnails: thumbnails
      )
      return model
   }
}

extension LiveBroadcastStreamModel.ContentDetails {
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel.ContentDetails {
      let monitorStream = LiveBroadcastStreamModel.MonitorStream.decode(json["monitorStream"])
      let model = LiveBroadcastStreamModel.ContentDetails (
         startWithSlate: json["startWithSlate"].boolValue,
         recordFromStart: json["recordFromStart"].boolValue,
         closedCaptionsType: json["closedCaptionsType"].stringValue,
         enableLowLatency: json["enableLowLatency"].boolValue,
         enableClosedCaptions: json["enableClosedCaptions"].boolValue,
         enableContentEncryption: json["enableContentEncryption"].boolValue,
         enableEmbed: json["enableEmbed"].boolValue,
         projection: json["projection"].stringValue,
         enableDvr: json["enableDvr"].boolValue,
         monitorStream: monitorStream,
         boundStreamId: json["boundStreamId"].stringValue
      )
      return model
   }
}

extension LiveBroadcastStreamModel.MonitorStream {
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel.MonitorStream {
      let model = LiveBroadcastStreamModel.MonitorStream (
         enableMonitorStream: json["enableMonitorStream"].boolValue,
         broadcastStreamDelayMs: json["broadcastStreamDelayMs"].intValue,
         embedHtml: json["embedHtml"].stringValue
      )
      return model
   }
}

extension LiveBroadcastStreamModel.Status {
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel.Status {
      let model = LiveBroadcastStreamModel.Status (
         lifeCycleStatus: json["lifeCycleStatus"].stringValue,
         recordingStatus: json["recordingStatus"].stringValue,
         privacyStatus: json["privacyStatus"].stringValue
      )
      return model
   }
}

extension LiveBroadcastStreamModel.Thumbnails {
   
   //                 thumbnails =                 {
   //                     default =                     {
   //                         height = 90;
   //                         url = "https://i.ytimg.com/vi/U8O8er6neBY/default_live.jpg";
   //                         width = 120;
   //                     };
   //                     high =                     {
   //                         height = 360;
   //                         url = "https://i.ytimg.com/vi/U8O8er6neBY/hqdefault_live.jpg";
   //                         width = 480;
   //                     };
   //                     medium =                     {
   //                         height = 180;
   //                         url = "https://i.ytimg.com/vi/U8O8er6neBY/mqdefault_live.jpg";
   //                         width = 320;
   //                     };
   //                 };
   
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel.Thumbnails {
      let def = LiveBroadcastStreamModel.Thumbnail.decode(json["default"])
      let height = LiveBroadcastStreamModel.Thumbnail.decode(json["high"])
      let medium = LiveBroadcastStreamModel.Thumbnail.decode(json["medium"])
      
      let model = LiveBroadcastStreamModel.Thumbnails (
         def: def,
         height: height,
         medium: medium
      )
      return model
   }
}

extension LiveBroadcastStreamModel.Thumbnail {
   public static func decode(_ json: JSON) -> LiveBroadcastStreamModel.Thumbnail {
      let model = LiveBroadcastStreamModel.Thumbnail (
         height: json["height"].intValue,
         url: json["url"].stringValue,
         width: json["width"].intValue
      )
      return model
   }
}

