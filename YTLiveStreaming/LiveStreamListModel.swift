//
//  LiveStreamListModel.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

// {
//   "etag" : "\"I_8xdZu766_FSaexEaDXTIfEWc0\/VMmvFScihZJoETVMe17uR2H6SXQ\"",
//   "kind" : "youtube//liveStreamListResponse",
//   "items" : [
//     {
//       "snippet" : {
//         "title" : "Live Stream",
//         "channelId" : "UCm4xprzPvVL8Uravaneq7CA",
//         "publishedAt" : "2016-10-17T10:45:32.000Z",
//         "description" : "Live Stream Description",
//         "isDefaultStream" : false
//       },
//       "etag" : "\"I_8xdZu766_FSaexEaDXTIfEWc0\/hxXAbPuAg4p-VmJHqKBp5Q38lPY\"",
//       "id" : "m4xprzPvVL8Uravaneq7CA1476701132194106",
//       "status" : {
//         "healthStatus" : {
//           "status" : "noData"
//         },
//         "streamStatus" : "ready"
//       },
//       "cdn" : {
//         "frameRate" : "60fps",
//         "ingestionInfo" : {
//           "backupIngestionAddress" : "rtmp:\/\/b.rtmp.youtube.com\/live2?backup=1",
//           "ingestionAddress" : "rtmp:\/\/a.rtmp.youtube.com\/live2",
//           "streamName" : "h8jh-dkhk-cjcm-0p18"
//         },
//         "resolution" : "720p",
//         "format" : "720p_hfr",
//         "ingestionType" : "rtmp"
//       },
//       "kind" : "youtube//liveStream"
//     }
//   ],
//   "pageInfo" : {
//     "totalResults" : 0,
//     "resultsPerPage" : 5
//   }
// }

public struct LiveStreamListModel {

   public struct Item {
      public let etag: String
      public let id: String
      public let kind: String
      public let snippet: Snipped
      public let status: Status
      public let cdn: CDN
   }
   
   public struct Snipped {
      public let title: String
      public let channelId: String
      public let publishedAt: String
      public let description: String
      public let isDefaultStream: Int
   }

   public struct HealthStatus {
      public let status: String
   }
   
   public struct Status {
      public let healthStatus: HealthStatus
      public let streamStatus: String
   }

   public struct IngestionInfo {
      public let streamName: String
      public let ingestionAddress: String
      public let backupIngestionAddress: String
   }
   
   public struct CDN {
      public let frameRate: String
      public let resolution: String
      public let format: String
      public let ingestionType: String
      public let ingestionInfo: IngestionInfo
   }
   
   public let etag: String
   public let kind: String
   public let items: [LiveStreamModel]
}

// MARK: - Decodable

extension LiveStreamListModel: Decodable {
   public static func decode(_ json: JSON) -> LiveStreamListModel {
      var items: [LiveStreamModel] = []
      if let content = json["items"].array {
         for item in content {
            let contentItem = LiveStreamModel.decode(item)
            items.append(contentItem)
         }
      }
      let model = LiveStreamListModel(
         etag: json["etag"].stringValue,
         kind: json["kind"].stringValue,
         items: items
      )
      return model
   }
}

extension LiveStreamListModel.Item {
   public static func decode(_ json: JSON) -> LiveStreamListModel.Item {
      let snippet = LiveStreamListModel.Snipped.decode(json["snippet"])
      let status = LiveStreamListModel.Status.decode(json["status"])
      let cdn = LiveStreamListModel.CDN.decode(json["cdn"])
      let model = LiveStreamListModel.Item (
         etag: json["etag"].stringValue,
         id: json["id"].stringValue,
         kind: json["kind"].stringValue,
         snippet: snippet,
         status: status,
         cdn: cdn
      )
      return model
   }
}

extension LiveStreamListModel.IngestionInfo {
   public static func decode(_ json: JSON) -> LiveStreamListModel.IngestionInfo {
      let model = LiveStreamListModel.IngestionInfo (
         streamName: json["streamName"].stringValue,
         ingestionAddress: json["ingestionAddress"].stringValue,
         backupIngestionAddress: json["backupIngestionAddress"].stringValue
      )
      return model
   }
}

extension LiveStreamListModel.CDN {
   public static func decode(_ json: JSON) -> LiveStreamListModel.CDN {
      let ingestionInfo = LiveStreamListModel.IngestionInfo.decode(json["ingestionInfo"])
      let model = LiveStreamListModel.CDN (
         frameRate: json["frameRate"].stringValue,
         resolution: json["resolution"].stringValue,
         format: json["format"].stringValue,
         ingestionType: json["ingestionType"].stringValue,
         ingestionInfo: ingestionInfo
      )
      return model
   }
}

extension LiveStreamListModel.Snipped {
   public static func decode(_ json: JSON) -> LiveStreamListModel.Snipped {
      let model = LiveStreamListModel.Snipped (
         title: json["title"].stringValue,
         channelId: json["channelId"].stringValue,
         publishedAt: json["publishedAt"].stringValue,
         description: json["description"].stringValue,
         isDefaultStream: json["isDefaultStream"].intValue
         )
      return model
   }
}

extension LiveStreamListModel.Status {
   public static func decode(_ json: JSON) -> LiveStreamListModel.Status {
      let healthStatus = LiveStreamListModel.HealthStatus.decode(json["healthStatus"])
      let model = LiveStreamListModel.Status (
         healthStatus: healthStatus,
         streamStatus: json["streamStatus"].stringValue
      )
      return model
   }
}

extension LiveStreamListModel.HealthStatus {
   public static func decode(_ json: JSON) -> LiveStreamListModel.HealthStatus {
      let model = LiveStreamListModel.HealthStatus (
         status: json["status"].stringValue
      )
      return model
   }
}
