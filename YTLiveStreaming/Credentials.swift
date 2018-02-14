//
//  Credentials.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 11/12/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class Credentials: NSObject {
   
   private static var _clientID: String?
   private static var _APIkey: String?
   private static let plistKeyClientID = "CLIENT_ID"
   private static let plistKeyAPIkey = "API_KEY"
   
   class var clientID: String {
      if Credentials._clientID == nil {
         if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
               if let clientID = plist[plistKeyClientID] as? String, !clientID.isEmpty {
                  Credentials._clientID = clientID
               }
            }
         }
      }
      assert(Credentials._clientID != nil, "Please put your Client ID to the Info.plist!")
      return Credentials._clientID!
   }
   
   class var APIkey: String {
      if Credentials._APIkey == nil {
         if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
               if let apiKey = plist[plistKeyAPIkey] as? String, !apiKey.isEmpty {
                  Credentials._APIkey = apiKey
               }
            }
         }
      }
      assert(Credentials._APIkey != nil, "Please put your APY key to the Info.plist!")
      return Credentials._APIkey!
   }
}
