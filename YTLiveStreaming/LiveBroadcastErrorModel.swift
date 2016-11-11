//
//  LiveBroadcastErrorModel.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

// {
//   "error" : {
//     "errors" : [
//       {
//         "domain" : "global",
//         "reason" : "required",
//         "locationType" : "header",
//         "location" : "Authorization",
//         "message" : "Login Required"
//       }
//     ],
//     "code" : 401,
//     "message" : "Login Required"
//   }
// }

public struct LiveBroadcastErrorModel {

   public struct Item {
      public let domain: String
      public let reason: String
      public let locationType: String
      public let location: String
      public let message: String
   }

   public let code: Int?
   public let message: String?
}

// MARK: - Decodable

extension LiveBroadcastErrorModel: Decodable {
   public static func decode(_ json: JSON) -> LiveBroadcastErrorModel {
      let model = LiveBroadcastErrorModel(
         code: json["code"].intValue,
         message: json["message"].stringValue
      )
      return model
   }
}
