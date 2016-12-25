//
//  GooglePlus.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/28/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation
import Moya
import Result

private func JSONResponseDataFormatter(_ data: Data) -> Data {
   do {
      let dataAsJSON = try JSONSerialization.jsonObject(with: data, options: [])
      let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
      return prettyData
   } catch {
      return data //fallback to original data if it cant be serialized
   }
}

let GooglePlusBaseURL = "https://www.googleapis.com/plus/v1"

let googleAPIrequestClosure = { (endpoint: Moya.Endpoint<GooglePlus>, done: @escaping MoyaProvider<GooglePlus>.RequestResultClosure) in
   GoogleOAuth2.sharedInstance.requestToken() { token in
      if let token = token {
         var request = endpoint.urlRequest! as URLRequest
         request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
         var nserror: NSError! = NSError(domain: "LiveStreamingAPIHttp", code: 0, userInfo: nil)
         let error = Moya.Error.underlying(nserror)
         done(Result(request, failWith: error))
      } else {
         var nserror: NSError! = NSError(domain: "GooglePlusHttp", code: 4000, userInfo: ["NSLocalizedDescriptionKey": "Failed Google OAuth2 request token"])
         let error = Moya.Error.underlying(nserror)
         let request = endpoint.urlRequest! as URLRequest
         done(Result(request, failWith: error))
      }
   }
}

let GooglePlusProvider = MoyaProvider<GooglePlus>(requestClosure: googleAPIrequestClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

enum GooglePlus {
   case userInfo([String: AnyObject])
}

extension GooglePlus: TargetType {
   public var baseURL: URL { return URL(string: GooglePlusBaseURL)! }
   
   public var method: Moya.Method {
      switch self {
      case .userInfo:
         return .get
      }
   }
   
   public var path: String {
      switch self {
      case .userInfo(_):
         return "/people/me"
      }
   }
   
   public var parameters: [String: Any]? {
      switch self {
      case .userInfo(let parameters):
         return parameters
      }
   }
   
   public var sampleData: Data {
      switch self {
      case .userInfo(_):
         return Data()
      }
   }
   
   public var multipartBody: [MultipartFormData]? {
      return []
   }
   
   public var task: Task {
      return .request
   }
   
}

public func googleAPIurl(_ route: TargetType) -> String {
   return route.baseURL.appendingPathComponent(route.path).absoluteString
}
