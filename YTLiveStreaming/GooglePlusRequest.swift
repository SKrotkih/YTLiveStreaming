//
//  GooglePlusRequest.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GooglePlusRequest: NSObject {

   // Scope: https://www.googleapis.com/auth/plus.profile.emails.read
   
   
   // https://www.googleapis.com/plus/v1/people/me
   // "auth": {
   //   "oauth2": {
   //    "scopes": {
   //     "https://www.googleapis.com/auth/plus.login": {
   //      "description": "Know the list of people in your circles, your age range, and language"
   //     },
   //     "https://www.googleapis.com/auth/plus.me": {
   //      "description": "Know who you are on Google"
   //     },
   //     "https://www.googleapis.com/auth/userinfo.email": {
   //      "description": "View your email address"
   //     },
   //     "https://www.googleapis.com/auth/userinfo.profile": {
   //      "description": "View your basic profile info"
   
   //
   //     }
   //    }
   //   }
   //  },
   //
   
   class func aboutMeInfo(completion: @escaping (GooglePlusAboutMeModel?) -> Void) {
      
      //GoogleOAuth2.sharedInstance.clearToken()
      
      let parameters: [String: AnyObject] = [:]
      GooglePlusProvider.request(GooglePlus.userInfo(parameters), completion: { result in
         switch result {
         case let .success(response):
            do {
               let json = try JSON(data: response.data)
               let error = json["error"]
               let message = error["message"].stringValue
               if !message.isEmpty {
                  print("Error while getting broadcast info: " + message)
                  completion(nil)
               } else {
                  //print(json)
                  let aboutMeInfo = GooglePlusAboutMeModel.decode(json)
                  completion(aboutMeInfo)
               }
            } catch {
               print("System Error: \(error.localizedDescription)")
               completion(nil)
            }
         case let .failure(error):
            print("System Error: \(error.localizedDescription)")
            completion(nil)
         }
      })
   }
}
