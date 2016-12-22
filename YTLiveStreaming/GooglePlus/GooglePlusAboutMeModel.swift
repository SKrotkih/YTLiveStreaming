//
//  GooglePlusAboutMeModel.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import SwiftyJSON

//  {
//   "placesLived" : [
//     {
//       "value" : "Kharkiv, Ukraine",
//       "primary" : true
//     }
//   ],
//   "name" : {
//     "familyName" : "Krotkih",
//     "givenName" : "Sergey"
//   },
//   "kind" : "plus#person",
//   "etag" : "\"FT7X6cYw9BSnPtIywEFNNGVVdio\/sUsFpRk3cGMyiFxo8Odq8LmxNIc\"",
//   "language" : "en",
//   "objectType" : "person",
//   "gender" : "male",
//    "emails" : [
//    {
//       "value" : "sergey.krotkih@gmail.com",
//       "type" : "account"
//    }
//    ],
//   "isPlusUser" : true,
//   "verified" : false,
//   "circledByCount" : 14,
//   "id" : "111354439375852817582",
//   "image" : {
//     "url" : "https:\/\/lh4.googleusercontent.com\/-IXto0axlLpI\/AAAAAAAAAAI\/AAAAAAAAB08\/dBJAEXAUEXY\/photo.jpg?sz=50",
//     "isDefault" : false
//   },
//   "displayName" : "Sergey Krotkih",
//   "url" : "https:\/\/plus.google.com\/111354439375852817582",
//   "organizations" : [
//     {
//       "primary" : false,
//       "endDate" : "1975",
//       "name" : "Рефтинская средняя школа 17",
//       "type" : "school"
//     },
//     {
//       "title" : "Software engineer",
//       "primary" : false,
//       "name" : "Quickoffice",
//       "type" : "work"
//     }
//   ]
// }



public struct GooglePlusAboutMeModel {
   public let id: String
   public let name: String
   public let emails: [String]
}

// MARK: - Decodable

extension GooglePlusAboutMeModel: Decodable {
   public static func decode(_ json: JSON) -> GooglePlusAboutMeModel {
      var emails: [String] = []
      if let content = json["emails"].array {
         for item in content {
            let imail = item["value"].stringValue
            emails.append(imail)
         }
      }
      let model = GooglePlusAboutMeModel(
         id: json["id"].stringValue,
         name: json["displayName"].stringValue,
         emails: emails
      )
      return model
   }
}
