//
//  LiveStreamingAPI.swift
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

let requestClosure = { (endpoint: Moya.Endpoint<LiveStreamingAPI>, done: @escaping MoyaProvider<LiveStreamingAPI>.RequestResultClosure) in
   GoogleOAuth2.sharedInstance.requestToken() { token in
      if let token = token {
         do {
            var request = try endpoint.urlRequest() as URLRequest
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
            var nserror: NSError! = NSError(domain: "LiveStreamingAPIHttp", code: 0, userInfo: nil)
            let error = MoyaError.underlying(nserror, nil)
            done(Result(request, failWith: error))
         }
         catch {
            
         }
      } else {
         do {
            let request = try endpoint.urlRequest() as URLRequest
            var nserror: NSError! = NSError(domain: "LiveStreamingAPIHttp", code: 4000, userInfo: ["NSLocalizedDescriptionKey": "Failed Google OAuth2 request token"])
            let error = MoyaError.underlying(nserror, nil)
            done(Result(request, failWith: error))
         }
         catch {
            
         }
      }
   }
}

let YouTubeLiveVideoProvider = MoyaProvider<LiveStreamingAPI>(requestClosure: requestClosure, plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

enum LiveStreamingAPI {
   case listBroadcasts([String: AnyObject])
   case liveBroadcast([String: AnyObject])
   case transitionLiveBroadcast([String: AnyObject])
   case deleteLiveBroadcast([String: AnyObject])
   case bindLiveBroadcast([String: AnyObject])
   case liveStream([String: AnyObject])
   case deleteLiveStream([String: AnyObject])
}

extension LiveStreamingAPI: TargetType {
   
   public var baseURL: URL { return URL(string: LiveAPI.BaseURL)! }
   
   public var path: String {
      switch self {
      case .listBroadcasts(_):
         return "/liveBroadcasts"
      case .liveBroadcast(_):
         return "/liveBroadcasts"
      case .transitionLiveBroadcast(_):
         return "/liveBroadcasts/transition"
      case .deleteLiveBroadcast(_):
         return "/liveBroadcasts"
      case .bindLiveBroadcast(_):
         return "/liveBroadcasts/bind"
      case .liveStream(_):
         return "/liveStreams"
      case .deleteLiveStream(_):
         return "/liveStreams"
      }
   }
   
   public var method: Moya.Method {
      switch self {
      case .listBroadcasts:
         return .get
      case .liveBroadcast:
         return .get
      case .transitionLiveBroadcast:
         return .post
      case .deleteLiveBroadcast:
         return .delete
      case .bindLiveBroadcast:
         return .post
      case .liveStream:
         return .get
      case .deleteLiveStream:
         return .delete
      }
   }
   
   public var task: Task {
      switch self {
      case .listBroadcasts(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      case .liveBroadcast(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      case .transitionLiveBroadcast(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      case .deleteLiveBroadcast(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      case .bindLiveBroadcast(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      case .liveStream(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      case .deleteLiveStream(let parameters):
         return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
      }
   }
   
   public var parameters: [String: Any]? {
      switch self {
      case .listBroadcasts(let parameters):
         return parameters
      case .liveBroadcast(let parameters):
         return parameters
      case .transitionLiveBroadcast(let parameters):
         return parameters
      case .deleteLiveBroadcast(let parameters):
         return parameters
      case .bindLiveBroadcast(let parameters):
         return parameters
      case .liveStream(let parameters):
         return parameters
      case .deleteLiveStream(let parameters):
         return parameters
         
      }
   }
   
   public var sampleData: Data {
      switch self {
      case .listBroadcasts(_):
         return Data()
      case .liveBroadcast(_):
         return Data()
      case .transitionLiveBroadcast(_):
         return Data()
      case .deleteLiveBroadcast(_):
         return Data()
      case .bindLiveBroadcast(_):
         return Data()
      case .liveStream(_):
         return Data()
      case .deleteLiveStream(_):
         return Data()
      }
   }
   
   public var multipartBody: [MultipartFormData]? {
      return []
   }
   
   var headers: [String : String]? {
      return ["Content-type": "application/json"]
   }
}

public func url(_ route: TargetType) -> String {
   return route.baseURL.appendingPathComponent(route.path).absoluteString
}
