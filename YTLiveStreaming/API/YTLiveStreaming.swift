//
//  YTLiveStreaming.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//

import Foundation

public enum YTLiveVideoState: String {
    case upcoming
    case active
    case completed
    case all
}

private let kOrderByPublishedAt = true

public class YTLiveStreaming: NSObject {
}

// MARK: Public methods interface

extension YTLiveStreaming {
    /**
     @param
     @return
     */
    public func getUpcomingBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void) {
        print("+\(#function)")
        getBroadcastList(.upcoming, completion)
    }
    /**
     @param
     @return
     */
    public func getLiveNowBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void) {
        print("+\(#function)")
        getBroadcastList(.active, completion)
    }
    /**
     @param
     @return
     */
    public func getCompletedBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void) {
        print("+\(#function)")
        getBroadcastList(.completed, completion)
    }
    /**
     @param
     @return
     */
    public func getAllBroadcasts(
        _ completion: @escaping ([LiveBroadcastStreamModel]?, [LiveBroadcastStreamModel]?, [LiveBroadcastStreamModel]?
        ) -> Void) {
        YTLiveRequest.listBroadcasts(.all) { result in
            switch result {
            case .success(let broadcasts):
                self.fillList(broadcasts, completion: { streams in
                    if let streams = streams {
                        var streamsReady = [LiveBroadcastStreamModel]()
                        var streamsLive = [LiveBroadcastStreamModel]()
                        var streamsComplete = [LiveBroadcastStreamModel]()
                        for item in streams {
                            let lifeCycleStatus = item.status?.lifeCycleStatus ?? "complete"
                            switch lifeCycleStatus {
                            case "ready":
                                streamsReady.append(item)
                            case "live":
                                streamsLive.append(item)
                            case "complete":
                                streamsComplete.append(item)
                            default:
                                break
                            }
                        }
                        completion(streamsReady, streamsLive, streamsComplete)
                    } else {
                        completion(nil, nil, nil)
                    }
                })
            case .failure(let error):
                print(error.message())
                completion(nil, nil, nil)
            }
        }
    }
    /**
     Create New Broadcast
     @param
     - title: The broadcast's title. Note that the broadcast represents exactly one YouTube video. You can set this field by modifying the broadcast resource or by setting the title field of the corresponding video resource.
      - description: The broadcast's description. As with the title, you can set this field by modifying the broadcast resource or by setting the description field of the corresponding video resource.
     - startTime: The date and time that the broadcast is scheduled to start. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. Creator Studio supports the ability to create a broadcast without scheduling a start time. In this case, the broadcast starts whenever the channel owner starts streaming. For these broadcasts, the datetime value corresponds to UNIX time zero, and this value cannot be changed via the API or in Creator Studio.
     - isReusable: Indicates whether the stream is reusable, which means that it can be bound to multiple broadcasts. It is common for broadcasters to reuse the same stream for many different broadcasts if those broadcasts occur at different times.
     - endDateTime:
     - selfDeclaredMadeForKids:
     - enableAutoStart:
     - enableAutoStop:
     - enableClosedCaptions:
     - enableDvr:
     - enableEmbed:
     - recordFromStart:
     - enableMonitorStream:
     - broadcastStreamDelayMs:
     @return
     */
    public func createBroadcast(_ body: PostLiveBroadcastBody,
                                completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void) {
        let liveStreamDescription = body.description.isEmpty ? "This stream was created by the YTLiveStreaming iOS framework" : body.description
        let liveStreamName = "YTLiveStreaming"
        YTLiveRequest.createLiveBroadcast(body: body) { result in
            switch result {
            case .success(let liveBroadcast):
                // Create Live stream
                YTLiveRequest.createLiveStream(
                    body.title,
                    description: liveStreamDescription,
                    streamName: liveStreamName,
                    isReusable: body.isReusable
                ) { result in
                    switch result {
                    case .success(let liveStream):
                        // Bind live stream
                        YTLiveRequest.bindLiveBroadcast(
                            broadcastId: liveBroadcast.id,
                            liveStreamId: liveStream.id,
                            completion: { result in
                                switch result {
                                case .success(let liveBroadcast):
                                    completion(.success(liveBroadcast))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        )
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    /**
     @param
     @return
     */
    public func updateBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void) {
        YTLiveRequest.updateLiveBroadcast(broadcast) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print(error.message())
                completion(false)
            }
        }
    }
    /**
     @param
     @return
     */
    public func startBroadcast(_ broadcast: LiveBroadcastStreamModel,
                               delegate: LiveStreamTransitioning,
                               completion: @escaping (String?, String?, Date?) -> Void) {
        let broadcastId = broadcast.id
        let liveStreamId = broadcast.contentDetails?.boundStreamId ?? ""
        if !broadcastId.isEmpty && !liveStreamId.isEmpty {
            YTLiveRequest.getLiveBroadcast(broadcastId: broadcastId) { result in
                switch result {
                case .success(let liveBroadcast):
                    YTLiveRequest.getLiveStream(liveStreamId, completion: { result in
                        switch result {
                        case .success(let liveStream):
                            let streamName = liveStream.cdn.ingestionInfo.streamName
                            let streamUrl = liveStream.cdn.ingestionInfo.ingestionAddress
                            let scheduledStartTime = liveBroadcast.snippet.scheduledStartTime ?? Date()

                            let sreamId = liveStream.id
                            let monitorStream = liveBroadcast.contentDetails?.monitorStream.embedHtml ?? ""
                            let streamTitle = liveStream.snipped.title

                            print("\n-BroadcastId=\(liveBroadcast.id);\n-Live stream id=\(sreamId); \n-title=\(streamTitle); \n-start=\(scheduledStartTime); \n-STREAM_URL=\(streamUrl)/STREAM_NAME=\(streamName): created!\n-MONITOR_STREAM=\(monitorStream)\n")

                            LiveLauncher.sharedInstance.youTubeWorker = self
                            LiveLauncher.sharedInstance.delegate = delegate
                            LiveLauncher.sharedInstance.launchBroadcast(broadcast: broadcast, stream: liveStream)
                            completion(streamName, streamUrl, scheduledStartTime)
                        case .failure(let error):
                            print(error.message())
                            completion(nil, nil, nil)
                        }
                    })
                case .failure(let error):
                    print(error.message())
                    print("Please xheck broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
                    completion(nil, nil, nil)
                }
            }
        } else {
            print("Please check broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
            completion(nil, nil, nil)
        }
    }
    /**
     @param
     @return
     */
    public func completeBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void) {
        LiveLauncher.sharedInstance.stopBroadcast()
        // complete – The broadcast is over. YouTube stops transmitting video.
        YTLiveRequest.transitionLiveBroadcast(broadcast.id, broadcastStatus: "complete") { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print(error.message())
                completion(false)
            }
        }
    }
    /**
     deleteAllBroadcastsAsync - async function deleting all broadcasts from the Ussr's account
     @param
     @return
        true if all broadcasts were deleted successfully. No error thrown.
     */
    public func deleteAllBroadcastsAsync() async -> Bool {
        let broadcastIDs: [String] = await withUnsafeContinuation { continuation in
            YTLiveRequest.listBroadcasts(.all, completion: { result in
                switch result {
                case .success(let broadcastList):
                    let broadcastIDs = broadcastList.items.map { $0.id }
                    continuation.resume(returning: broadcastIDs)
                case .failure(let error):
                    print(error.message())
                    return continuation.resume(returning: [])
                }
            })
        }
        return await deleteBroadcastsAsync(broadcastIDs)
    }
    /**
     deleteBroadcasts - async function deleting broadcasts by IDs
     @param
        broadcastsIDs - array of IDs which broadcasts will be deleted
     @return
        true if all broadcasts were deleted successfully
     */
    public func deleteBroadcastsAsync(_ broadcastIDs: [String]) async -> Bool {
        let _deletedIDs = await withTaskGroup(of: [String].self,
                                              returning: [String].self,
                                              body: { taskGroup in
            broadcastIDs.forEach { broadcastID in
                taskGroup.addTask {
                    let result = await withUnsafeContinuation { continuation in
                        self.deleteBroadcast(id: broadcastID) { result in
                            continuation.resume(returning: result)
                        }
                    }
                    switch result {
                    case .success():
                        return [broadcastID]
                    default:
                        return []
                    }
                }
            }
            var _deletedIDs = [String]()
            for await ids in taskGroup {
                _deletedIDs.append(contentsOf: ids)
            }
            return _deletedIDs
        })
        return _deletedIDs.count == broadcastIDs.count
    }
    /**
     @param
     @return
     */
    public func deleteBroadcast(id: String, completion: @escaping ((Result<Void, YTError>)) -> Void) {
        YTLiveRequest.deleteLiveBroadcast(broadcastId: id) { result in
            completion(result)
        }
    }
    /**
     @param
     @return
     */
    public func transitionBroadcast(_ broadcast: LiveBroadcastStreamModel,
                                    toStatus: String,
                                    completion: @escaping (Bool) -> Void) {
        // complete – The broadcast is over. YouTube stops transmitting video.
        // live – The broadcast is visible to its audience. YouTube transmits video to the broadcast's
        // monitor stream and its broadcast stream.
        // testing – Start testing the broadcast. YouTube transmits video to the broadcast's monitor stream.
        YTLiveRequest.transitionLiveBroadcast(broadcast.id, broadcastStatus: toStatus) { result in
            switch result {
            case .success:
                print("Our broadcast in the \(toStatus) status!")
                completion(true)
            case .failure(let error):
                print(error.message)
                completion(false)
            }
        }
    }
    /**
     @param
     @return
     */
    public func getStatusBroadcast(_ broadcast: LiveBroadcastStreamModel,
                                   stream: LiveStreamModel,
                                   completion: @escaping (String?, String?, String?) -> Void) {
        YTLiveRequest.getLiveBroadcast(broadcastId: broadcast.id, completion: { result in
            switch result {
            case .success(let broadcast):
                let broadcastStatus = broadcast.status?.lifeCycleStatus ?? "complete"

                // Valid values for this property are:
                //  abandoned – This broadcast was never started.
                //  complete – The broadcast is finished.
                //  created – The broadcast has incomplete settings, so it is not ready to transition
                //            to a live or testing status, but it has been created and is otherwise valid.
                //  live – The broadcast is active.
                //  liveStarting – The broadcast is in the process of transitioning to live status.
                //  ready – The broadcast settings are complete and the broadcast can transition
                //          to a live or testing status.
                //  reclaimed – This broadcast has been reclaimed.
                //  revoked – This broadcast was removed by an admin action.
                //  testStarting – The broadcast is in the process of transitioning to testing status.
                //  testing – The broadcast is only visible to the partner.

                YTLiveRequest.getLiveStream(stream.id, completion: { result in
                    switch result {
                    case .success(let liveStream):
                        // Valid values for this property are:
                        //  active – The stream is in active state which means the user is receiving
                        //           data via the stream.
                        //  created – The stream has been created but does not have valid CDN settings.
                        //  error – An error condition exists on the stream.
                        //  inactive – The stream is in inactive state which means the user is not
                        //             receiving data via the stream.
                        //  ready – The stream has valid CDN settings.
                        let streamStatus = liveStream.status.streamStatus

                        // Valid values for this property are:
                        //  good – There are no configuration issues for which the severity is warning or worse.
                        //  ok – There are no configuration issues for which the severity is error.
                        //  bad – The stream has some issues for which the severity is error.
                        //  noData – YouTube's live streaming backend servers do not have any information
                        //           about the stream's health status.
                        let healthStatus = liveStream.status.healthStatus.status
                        completion(broadcastStatus, streamStatus, healthStatus)
                    case .failure(let error):
                        print(error.message())
                        completion(nil, nil, nil)
                    }
                })
            case .failure(let error):
                print(error.message())
                completion(nil, nil, nil)
            }
        })
    }
    /**
     @param
     @return
     */
    public func transitionBroadcastToLiveState(liveBroadcast: LiveBroadcastStreamModel,
                                               liveState: @escaping (Bool) -> Void) {
        self.transitionBroadcast(liveBroadcast, toStatus: "live") { success in
            if success {
                print("Transition to the LIVE status was made successfully")
                liveState(true)
            } else {
                print("Failed transition to the LIVE status!")
                liveState(false)
                self.transitionBroadcast(liveBroadcast, toStatus: "testing", completion: { success in
                    if success {
                        print("We in the testing status!")
                    }
                })
            }
        }
    }
    /**
     @param
     @return
     */
    public func isYouTubeAvailable() -> Bool {
        return GoogleOAuth2.sharedInstance.isAccessTokenPresented
    }
}

// MARK: Private methods

extension YTLiveStreaming {
    fileprivate func getBroadcastList(
        _ status: YTLiveVideoState, _ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void
    ) {
        YTLiveRequest.listBroadcasts(status) { result in
            switch result {
            case .success(let broadcasts):
                self.fillList(broadcasts) { list in
                    if let list = list {
                        completion(.success(list))
                    } else {
                        completion(.failure(.message("Parse error")))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    fileprivate func fillList(
        _ broadcasts: LiveBroadcastListModel, completion: ([LiveBroadcastStreamModel]?) -> Void
    ) {
        let items = broadcasts.items
        if kOrderByPublishedAt {
            let sortedItems = items.sorted(by: {
                $0.snippet.publishedAt.compare($1.snippet.publishedAt) == ComparisonResult.orderedDescending
            })
            completion(sortedItems)
        } else {
            let sortedItems = items.sorted(by: {
                $0.snippet.scheduledStartTime?.compare($1.snippet.scheduledStartTime ?? Date()) == ComparisonResult.orderedDescending
            })
            completion(sortedItems)
        }
    }
}

// MARK: - Tests

extension YTLiveStreaming {
    func testUpdateLiveStream() {
        let liveStreamId = "0"
        let title = "Live Stream"
        let description = "Live Stream created with YTLiveStreaming framework"
        let frameRate = ""
        let ingestionType = "rtmp" // dash rtmp
        let resolution = "1080p"
        YTLiveRequest.updateLiveStream(liveStreamId,
                                       title: title,
                                       description: description,
                                       frameRate: frameRate,
                                       ingestionType: ingestionType,
                                       resolution: resolution,
                                       completion: { result in
            switch result {
            case .success:
                print("All right")
            case .failure(let error):
                print(error.message())
            }
        })
    }
}
