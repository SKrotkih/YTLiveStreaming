//
//  YTLiveRequest.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class YTLiveRequest: NSObject {
    // Set up broadcast on your Youtube account:
    // https://www.youtube.com/my_live_events
    // https://www.youtube.com/live_dashboard
    // Errors:
    // https://support.google.com/youtube/answer/3006768?hl=ru

    // Developer console
    // https://console.developers.google.com/apis/credentials/key/0?project=fightnights-143711
}

// MARK: LiveBroatcasts requests
// https://developers.google.com/youtube/v3/live/docs/liveBroadcasts

extension YTLiveRequest {

    class func getHeaders(_ completion: @escaping (HTTPHeaders?) -> Void) {
        GoogleOAuth2.sharedInstance.requestToken { token in
            if let token = token {
                var headers: HTTPHeaders = [.contentType("application/json")]
                headers.add(.accept("application/json"))
                headers.add(.authorization("Bearer \(token)"))
                completion(headers)
            } else {
                completion(nil)
            }
        }
    }

    // Returns a list of YouTube broadcasts that match the API request parameters.
    // broadcastStatus:
    // Acceptable values are:
    // active – Return current live broadcasts.
    // all – Return all broadcasts.
    // completed – Return broadcasts that have already ended.
    // upcoming – Return broadcasts that have not yet started.
    class func listBroadcasts(_ status: YTLiveVideoState,
                              completion: @escaping (Result<LiveBroadcastListModel, YTError>) -> Void) {
        let parameters: [String: AnyObject] = [
            "part": "id,snippet,contentDetails,status" as AnyObject,
            "broadcastStatus": status.rawValue as AnyObject,
            "maxResults": LiveRequest.MaxResultObjects as AnyObject,
            "key": Credentials.APIkey as AnyObject
        ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.listBroadcasts(parameters), completion: { result in
            switch result {
            case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(LiveBroadcastListModel.self, from: response.data)
                    let totalResults = response.pageInfo.totalResults
                    let resultsPerPage = response.pageInfo.resultsPerPage

                    print("Broadcasts total count = \(totalResults)")

                    if totalResults > resultsPerPage {
                        // TODO: In this case you should send request
                        // with pageToken=nextPageToken or pageToken=prevPageToken parameter
                        print("Need to read next page!")
                    }
                    completion(.success(response))
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        })
    }

    class func getLiveBroadcast(broadcastId: String,
                                completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void) {
        let parameters: [String: AnyObject] =
            [
                "part": "id,snippet,contentDetails,status" as AnyObject,
                "id": broadcastId as AnyObject,
                "key": Credentials.APIkey as AnyObject
            ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.liveBroadcast(parameters)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let error = json["error"]
                    let message = error["message"].stringValue
                    if !message.isEmpty {
                        completion(.failure(.message("Error while request broadcast list" + message)))
                    } else {
                        let decoder = JSONDecoder()
                        let broadcastList = try decoder.decode(LiveBroadcastListModel.self, from: response.data)
                        let items = broadcastList.items
                        if let broadcast = items.first(where: { $0.id == broadcastId }) {
                            completion(.success(broadcast))
                        } else {
                            completion(.failure(.message("broadcast does not exist")))
                        }
                    }
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        }
    }

    // https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/insert
    // Creates a broadcast.
    class func createLiveBroadcast(_ title: String,
                                   _ description: String,
                                   startDateTime: Date,
                                   privacy: String?,
                                   enableAutoStop: Bool?,
                                   enableEmbed: Bool?,
                                   completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void) {
        getHeaders { headers in
            guard let headers = headers else {
                completion(.failure(.message("OAuth token is not presented")))
                return
            }
            let jsonBody = CreateLiveBroadcastBody(title: title, description: description, startDateTime: startDateTime, privacy: privacy, enableAutoStop: enableAutoStop, enableEmbed: enableEmbed)
            guard let jsonData = try? JSONEncoder().encode(jsonBody),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                completion(.failure(.message("Failed while preparing request")))
                return
            }
            let encoder = JSONBodyStringEncoding(jsonBody: jsonString)
            let parameters = "liveBroadcasts?part=id,snippet,contentDetails,status&key=\(Credentials.APIkey)"
            let url = "\(LiveAPI.BaseURL)/\(parameters)"
            AF.request(url, method: .post, parameters: [:], encoding: encoder, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            completion(.failure(.message("create liveBroadcasts response is empty")))
                            return
                        }
                        do {
                            let json = try JSON(data: data)
                            let error = json["error"].stringValue
                            if !error.isEmpty {
                                let message = json["message"].stringValue
                                completion(.failure(.message("Error while Youtube broadcast was creating: \(message)")))
                            } else {
                                // print(json)
                                let decoder = JSONDecoder()
                                let liveBroadcast = try decoder.decode(LiveBroadcastStreamModel.self, from: data)
                                completion(.success(liveBroadcast))
                            }
                        } catch {
                            let message = "Parsing data error: \(error.localizedDescription)"
                            completion(.failure(.message(message)))
                        }
                    case .failure(let error):
                        let code = error.responseCode ?? -1
                        let message = error.errorDescription ?? error.localizedDescription
                        completion(.failure(.systemMessage(code, message)))
                    }
                }.cURLDescription { (description) in
                    print("\n====== REQUEST =======\n\(description)\n==============\n")
                }
        }
    }

    // Updates a broadcast. For example, you could modify the broadcast settings defined
    // in the liveBroadcast resource's contentDetails object.
    // https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/update
    // PUT https://www.googleapis.com/youtube/v3/liveBroadcasts
    class func updateLiveBroadcast(_ broadcast: LiveBroadcastStreamModel,
                                   completion: @escaping (Result<Void, YTError>) -> Void) {
        getHeaders { headers in
            guard let headers = headers else {
                completion(.failure(.message("OAuth token is not presented")))
                return
            }
            let jsonBody = UpdateLiveBroadcastBody(broadcast: broadcast)
            guard let jsonData = try? JSONEncoder().encode(jsonBody),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                completion(.failure(.message("Failed while preparing request")))
                return
            }
            let encoder = JSONBodyStringEncoding(jsonBody: jsonString)
            let parameters = "liveBroadcasts?part=id,snippet,contentDetails,status&key=\(Credentials.APIkey)"
            AF.request("\(LiveAPI.BaseURL)/\(parameters)",
                method: .put,
                parameters: [:],
                encoding: encoder,
                headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            completion(.failure(.message("update broadcast response is empty")))
                            return
                        }
                        do {
                            let json = try JSON(data: data)
                            let error = json["error"].stringValue
                            if !error.isEmpty {
                                let message = json["message"].stringValue
                                completion(.failure(.message("Error while Youtube broadcast was creating" + message)))
                            } else {
                                completion(.success(Void()))
                            }
                        } catch {
                            let message = "Parsing data error: \(error.localizedDescription)"
                            completion(.failure(.message(message)))
                        }
                    case .failure(let error):
                        let code = error.responseCode ?? -1
                        let message = error.errorDescription ?? error.localizedDescription
                        completion(.failure(.systemMessage(code, message)))
                    }
            }.cURLDescription { (description) in
                print("\n====== REQUEST =======\n\(description)\n==============\n")
            }
        }
    }

    // POST https://www.googleapis.com/youtube/v3/liveBroadcasts/transition
    // Changes the status of a YouTube live broadcast and initiates any processes associated with the new status.
    // For example, when you transition a broadcast's status to testing, YouTube starts to transmit video
    // to that broadcast's monitor stream. Before calling this method, you should confirm that the value of the
    // status.streamStatus property for the stream bound to your broadcast is active.
    class func transitionLiveBroadcast(_ boadcastId: String,
                                       broadcastStatus: String,
                                       completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void) {

        let parameters: [String: AnyObject] = [
            "id": boadcastId as AnyObject,
            "broadcastStatus": broadcastStatus as AnyObject,
            "part": "id,snippet,contentDetails,status" as AnyObject,
            "key": Credentials.APIkey as AnyObject
        ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.transitionLiveBroadcast(parameters)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let error = json["error"]
                    let message = error["message"].stringValue
                    if !message.isEmpty {
                        // print("Error while Youtube broadcast transition", message: message)
                        let text = "FAILED TRANSITION TO THE \(broadcastStatus) STATUS [\(message)]!"
                        completion(.failure(.message(text)))
                    } else {
                        // print(json)
                        let decoder = JSONDecoder()
                        let liveBroadcast = try decoder.decode(LiveBroadcastStreamModel.self, from: response.data)
                        completion(.success(liveBroadcast))
                    }
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        }
    }

    // Deletes a broadcast.
    // DELETE https://www.googleapis.com/youtube/v3/liveBroadcasts
    class func deleteLiveBroadcast(broadcastId: String, completion: @escaping (Result<Void, YTError>) -> Void) {
        let parameters: [String: AnyObject] = [
            "id": broadcastId as AnyObject,
            "key": Credentials.APIkey as AnyObject
        ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.deleteLiveBroadcast(parameters)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let error = LiveBroadcastErrorModel.decode(json["error"])
                    if let code = error.code, code > 0 {
                        completion(.failure(.message("Failed of deleting broadcast: " + error.message!)))
                    } else {
                        // print("Broadcast deleted: \(json)")
                        completion(.success(Void()))
                    }
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        }
    }

    // Binds a YouTube broadcast to a stream or removes an existing binding between a broadcast and a stream.
    // A broadcast can only be bound to one video stream, though a video stream may be bound to more than one broadcast.
    // POST https://www.googleapis.com/youtube/v3/liveBroadcasts/bind
    class func bindLiveBroadcast(broadcastId: String,
                                 liveStreamId streamId: String,
                                 completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void) {
        let parameters: [String: AnyObject] = [
            "id": broadcastId as AnyObject,
            "streamId": streamId as AnyObject,
            "part": "id,snippet,contentDetails,status" as AnyObject,
            "key": Credentials.APIkey as AnyObject
        ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.bindLiveBroadcast(parameters)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let error = json["error"]
                    let message = error["message"].stringValue
                    if !message.isEmpty {
                        let text = "Error while Youtube broadcast binding with live stream: \(message)"
                        completion(.failure(.message(text)))
                    } else {
                        // print(json)
                        let decoder = JSONDecoder()
                        let liveBroadcast = try decoder.decode(LiveBroadcastStreamModel.self, from: response.data)
                        completion(.success(liveBroadcast))
                    }
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        }
    }
}

// MARK: LiveStreams requests
// https://developers.google.com/youtube/v3/live/docs/liveStreams
// A liveStream resource contains information about the video stream that you are transmitting to YouTube.
// The stream provides the content that will be broadcast to YouTube users.
// Once created, a liveStream resource can be bound to one or more liveBroadcast resources.
extension YTLiveRequest {
    // Returns a list of video streams that match the API request parameters.
    // https://developers.google.com/youtube/v3/live/docs/liveStreams/list
    class func getLiveStream(_ liveStreamId: String, completion: @escaping (Result<LiveStreamModel, YTError>) -> Void) {
        let parameters: [String: AnyObject] = [
            "part": "id,snippet,cdn,status" as AnyObject,
            "id": liveStreamId as AnyObject,
            "key": Credentials.APIkey as AnyObject
        ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.liveStream(parameters)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let error = json["error"]
                    let message = error["message"].stringValue
                    if !message.isEmpty {
                        completion(.failure(.message("Error while Youtube broadcast creating: " + message)))
                    } else {
                        // print(json)
                        let broadcastList = LiveStreamListModel.decode(json)
                        let items = broadcastList.items
                        var liveStream: LiveStreamModel?
                        for item in items where item.id == liveStreamId {
                            liveStream = item
                        }
                        if liveStream != nil {
                            completion(.success(liveStream!))
                        } else {
                            completion(.failure(.message("liveStream is empty")))
                        }
                    }
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        }
    }

    // https://developers.google.com/youtube/v3/live/docs/liveStreams/insert
    // Creates a video stream. The stream enables you to send your video to YouTube,
    // which can then broadcast the video to your audience.
    //   POST https://www.googleapis.com/youtube/v3/liveStreams?part=id%2Csnippet%2Ccdn%2Cstatus&key={YOUR_API_KEY}
    class func createLiveStream(_ title: String,
                                description: String,
                                streamName: String,
                                completion: @escaping (Result<LiveStreamModel, YTError>) -> Void) {
        getHeaders { headers in
            guard let headers = headers else {
                completion(.failure(.message("OAuth token is not presented")))
                return
            }
            let jsonBody = CreateLiveStreamBody(title: title, description: description, streamName: streamName)
            guard let jsonData = try? JSONEncoder().encode(jsonBody),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                completion(.failure(.message("Failed while preparing request")))
                return
            }
            let encoder = JSONBodyStringEncoding(jsonBody: jsonString)
            let url = "\(LiveAPI.BaseURL)/liveStreams?part=id,snippet,cdn,status&key=\(Credentials.APIkey)"
            AF.request(url, method: .post, parameters: [:], encoding: encoder, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            completion(.failure(.message("createLiveStream response is empty")))
                            return
                        }
                        do {
                            let json = try JSON(data: data)
                            let error = json["error"]
                            if !error.isEmpty {
                                let message = json["message"].stringValue
                                completion(.failure(.message("Error while Youtube broadcast was creating: " + message)))
                            } else {
                                let liveStream = LiveStreamModel.decode(json)
                                completion(.success(liveStream))
                            }
                        } catch {
                            let message = "Parsing data error: \(error.localizedDescription)"
                            completion(.failure(.message(message)))
                        }
                    case .failure(let error):
                        let code = error.responseCode ?? -1
                        let message = error.errorDescription ?? error.localizedDescription
                        completion(.failure(.systemMessage(code, message)))
                    }
            }.cURLDescription { (description) in
                print("\n====== REQUEST =======\n\(description)\n==============\n")
            }
        }
    }

    // Deletes a video stream
    // Request:
    // DELETE https://www.googleapis.com/youtube/v3/liveStreams
    class func deleteLiveStream(_ liveStreamId: String, completion: @escaping (Result<Void, YTError>) -> Void) {
        let parameters: [String: AnyObject] = [
            "id": liveStreamId as AnyObject,
            "key": Credentials.APIkey as AnyObject
        ]
        youTubeLiveVideoProvider.request(LiveStreamingAPI.deleteLiveStream(parameters)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    let error = json["error"].stringValue
                    if !error.isEmpty {
                        let message = json["message"].stringValue
                        completion(.failure(.message(error + ";" + message)))
                    } else {
                        print("video stream deleted: \(json)")
                        completion(.success(Void()))
                    }
                } catch {
                    let message = "Parsing data error: \(error.localizedDescription)"
                    completion(.failure(.message(message)))
                }
            case let .failure(error):
                let code = error.errorCode
                let message = error.errorDescription ?? error.localizedDescription
                completion(.failure(.systemMessage(code, message)))
            }
        }
    }

    // Updates a video stream. If the properties that you want to change cannot be updated,
    // then you need to create a new stream with the proper settings.
    // Request:
    // PUT https://www.googleapis.com/youtube/v3/liveStreams
    // format = 1080p 1440p 240p 360p 480p 720p
    // ingestionType = dash rtmp
    class func updateLiveStream(_ liveStreamId: String,
                                title: String,
                                format: String,
                                ingestionType: String,
                                completion: @escaping (Result<Void, YTError>) -> Void) {
        getHeaders { headers in
            guard let headers = headers else {
                completion(.failure(.message("OAuth token is not presented")))
                return
            }
            let jsonBody = UpdateLiveStreamBody(id: liveStreamId, title: title, format: format, ingestionType: ingestionType)
            guard let jsonData = try? JSONEncoder().encode(jsonBody),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                completion(.failure(.message("Failed while preparing request")))
                return
            }
            let encoder = JSONBodyStringEncoding(jsonBody: jsonString)
            AF.request("\(LiveAPI.BaseURL)/liveStreams",
                method: .put,
                parameters: ["part": "id,snippet,cdn,status", "key": Credentials.APIkey],
                encoding: encoder,
                headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            completion(.failure(.message("updateLiveStream response is empty")))
                            return
                        }
                        do {
                            let json = try JSON(data: data)
                            let error = json["error"].stringValue
                            if !error.isEmpty {
                                let message = json["message"].stringValue
                                completion(.failure(.message("Error while Youtube broadcast was creating" + message)))
                            } else {
                                completion(.success(Void()))
                            }
                        } catch {
                            let message = "Parsing data error: \(error.localizedDescription)"
                            completion(.failure(.message(message)))
                        }
                    case .failure(let error):
                        let code = error.responseCode ?? -1
                        let message = error.errorDescription ?? error.localizedDescription
                        completion(.failure(.systemMessage(code, message)))
                    }
                }.cURLDescription { (description) in
                    print("\n====== REQUEST =======\n\(description)\n==============\n")
                }
        }
    }
}
