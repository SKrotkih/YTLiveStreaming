//
//  GoogleOAuth2.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/28/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

// Developer console
// https://console.developers.google.com/apis

// Create your own clientID at https://console.developers.google.com/project (secret can be left blank!)
// For more info see https://developers.google.com/identity/protocols/OAuth2WebServer#handlingtheresponse
// And https://developers.google.com/+/web/api/rest/oauth

public class GoogleOAuth2: NSObject {

   let keychain:  Keychain
   let kOAuth2AccessTokenService: String = "OAuth2AccessToken"
   
   public class var sharedInstance: GoogleOAuth2 {
      struct Singleton {
         static let instance = GoogleOAuth2()
      }
      return Singleton.instance
   }
   
   override init() {
      self.keychain = Keychain(service: LiveAPI.BaseURL)
      super.init()
   }

   var isAccessTokenPresented: Bool {
      return accessToken != nil
   }

   public var accessToken: String? {
      didSet {
         keychain[kOAuth2AccessTokenService] = accessToken
      }
   }

   public func clearToken() {
      keychain[kOAuth2AccessTokenService] = nil
   }
   
   func requestToken(_ completion: @escaping (String?) -> Void) {
      completion(accessToken)
   }
}
