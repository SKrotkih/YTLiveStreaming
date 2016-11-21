//
//  Credentials.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 11/12/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class Credentials: NSObject {
   static var _clientID: String?
   static var _APIkey: String?
   
   class var clientID: String {
      if Credentials._clientID == nil {
         if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
               if let clientID = plist["YTClientID"] as? String {
                  if clientID.characters.count > 0 {
                     Credentials._clientID = clientID
                  }
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
               if let apiKey = plist["YTAPIkey"] as? String {
                  if apiKey.characters.count > 0 {
                     Credentials._APIkey = apiKey
                  }
               }
            }
         }
      }
      assert(Credentials._APIkey != nil, "Please put your APY key to the Info.plist!")
      return Credentials._APIkey!
   }
}
