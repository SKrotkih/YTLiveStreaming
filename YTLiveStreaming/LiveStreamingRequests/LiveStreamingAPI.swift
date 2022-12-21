//
//  LiveStreamingAPI.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/28/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//
import Foundation
import Moya

let youTubeLiveVideoProvider = MoyaProvider<LiveStreamingAPI>(
    requestClosure: requestClosure, plugins: [NetworkLoggerPlugin()]
)

fileprivate let requestClosure = { (endpoint: Moya.Endpoint, done: @escaping MoyaProvider<LiveStreamingAPI>.RequestResultClosure) in
    GoogleOAuth2.sharedInstance.requestToken { token in
        if let token {
            do {
                var request = try endpoint.urlRequest() as URLRequest
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
                done(.success(request))
            } catch {
                var nserror: NSError! = NSError(
                    domain: "LiveStreamingAPIHttp",
                    code: 4000,
                    userInfo: ["NSLocalizedDescriptionKey": "Failed Google OAuth2 request token"]
                )
                let error = MoyaError.underlying(nserror, nil)
                done(.failure(error))
            }
        } else {
            var nserror: NSError! = NSError(
                domain: "LiveStreamingAPIHttp",
                code: 4000,
                userInfo: ["NSLocalizedDescriptionKey": "Failed Google OAuth2 request token"]
            )
            let error = MoyaError.underlying(nserror, nil)
            done(.failure(error))
        }
    }
}

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
        case .listBroadcasts:
            return "/liveBroadcasts"
        case .liveBroadcast:
            return "/liveBroadcasts"
        case .transitionLiveBroadcast:
            return "/liveBroadcasts/transition"
        case .deleteLiveBroadcast:
            return "/liveBroadcasts"
        case .bindLiveBroadcast:
            return "/liveBroadcasts/bind"
        case .liveStream:
            return "/liveStreams"
        case .deleteLiveStream:
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
        let parameters = {
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
        }()
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }

    public var sampleData: Data {
        switch self {
        case .listBroadcasts:
            return Data()
        case .liveBroadcast:
            return Data()
        case .transitionLiveBroadcast:
            return Data()
        case .deleteLiveBroadcast:
            return Data()
        case .bindLiveBroadcast:
            return Data()
        case .liveStream:
            return Data()
        case .deleteLiveStream:
            return Data()
        }
    }

    public var multipartBody: [MultipartFormData]? {
        return []
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
