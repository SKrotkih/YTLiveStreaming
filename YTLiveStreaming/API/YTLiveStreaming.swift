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
        getBroadcastList(.upcoming, completion: completion)
    }
    /**
     @param
     @return
     */
    public func getLiveNowBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void) {
        getBroadcastList(.active, completion: completion)
    }
    /**
     @param
     @return
     */
    public func getCompletedBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void) {
        getBroadcastList(.completed, completion: completion)
    }
    /**
     Deprecated
     @param
     @return
     */
    public func getAllBroadcasts(
        _ completion: @escaping ([LiveBroadcastStreamModel], [LiveBroadcastStreamModel], [LiveBroadcastStreamModel]
        ) -> Void) throws {
        Task {
            do {
                let broadcastList = try await getBroadcastListAsync(.all)
                var streamsReady = [LiveBroadcastStreamModel]()
                var streamsLive = [LiveBroadcastStreamModel]()
                var streamsComplete = [LiveBroadcastStreamModel]()
                for listItem in broadcastList {
                    let lifeCycleStatus = listItem.status?.lifeCycleStatus ?? "complete"
                    switch lifeCycleStatus {
                    case "ready":
                        streamsReady.append(listItem)
                    case "live":
                        streamsLive.append(listItem)
                    case "complete":
                        streamsComplete.append(listItem)
                    default:
                        break
                    }
                }
                completion(streamsReady, streamsLive, streamsComplete)
            } catch {
                throw error
            }
        }
    }
    /**
     Returns Broadcast List
     @param
     @return
      [LiveBroadcastStreamModel]
     */
    public func getBroadcastListAsync(_ status: YTLiveVideoState) async throws -> [LiveBroadcastStreamModel] {
        let result: Result<[LiveBroadcastStreamModel], YTError> = await withUnsafeContinuation { continuation in
            YTLiveRequest.listBroadcasts(status) { result in
                switch result {
                case .success(let broadcasts):
                    // sort items either published or scheduled date
                    let items = broadcasts.items
                    if kOrderByPublishedAt {
                        let sortedItems = items.sorted(by: {
                            $0.snippet.publishedAt.compare($1.snippet.publishedAt) == ComparisonResult.orderedDescending
                        })
                        continuation.resume(returning: .success(sortedItems))
                    } else {
                        let sortedItems = items.sorted(by: {
                            $0.snippet.scheduledStartTime?.compare($1.snippet.scheduledStartTime ?? Date()) == ComparisonResult.orderedDescending
                        })
                        continuation.resume(returning: .success(sortedItems))
                    }
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        switch result {
        case .success(let broadcastList):
            return broadcastList
        case .failure(let error):
            throw error
        }
    }
    /**
     Create a New Broadcast
     @param
      body: PostLiveBroadcastBody
     @return
     */
    public func createBroadcastAsync(_ body: PostLiveBroadcastBody) async throws -> LiveBroadcastStreamModel {
        let result: Result<LiveBroadcastStreamModel, YTError> = await withUnsafeContinuation { continuation in
            createBroadcast(body) { result in
                switch result {
                case .success(let broadcast):
                    continuation.resume(returning: .success(broadcast))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        switch result {
        case .success(let broadcastList):
            return broadcastList
        case .failure(let error):
            throw error
        }
    }
    
    public func createBroadcast(_ body: PostLiveBroadcastBody,
                                liveStreamName: String = "YTLiveStreaming",
                                completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void) {
        let liveStreamDescription = body.description.isEmpty ? "This stream was created by the YTLiveStreaming iOS framework" : body.description
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
     Deprecated: Update Broadcast
     @param
     @return
     */
    public func updateBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await updateBroadcastAsync(broadcast)
                completion(true)
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    /**
     Update Broadcast
     @param
     @return
     */
    public func updateBroadcastAsync(_ broadcast: LiveBroadcastStreamModel) async throws {
        let result: Result<Void, YTError> = await withUnsafeContinuation { continuation in
            YTLiveRequest.updateLiveBroadcast(broadcast) { result in
                continuation.resume(returning: result)
            }
        }
        switch result {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    /**
     Deprecated. Please use async version
     @param
     @return
     */
    public func startBroadcast(_ broadcast: LiveBroadcastStreamModel,
                               delegate: LiveStreamTransitioning,
                               completion: @escaping (String?, String?, Date?) -> Void) {
        Task {
            do {
                let result = try await startBroadcastAsync(broadcast, delegate: delegate)
                completion(result.0, result.1, result.2)
            }
            catch {
                completion(nil, nil, nil)
            }
        }
    }
    /**
     @param
     @return
     */
    public func startBroadcastAsync(_ broadcast: LiveBroadcastStreamModel,
                                    delegate: LiveStreamTransitioning) async throws -> (String?, String?, Date?) {
        let broadcastId = broadcast.id
        let liveStreamId = broadcast.contentDetails?.boundStreamId ?? ""
        if !broadcastId.isEmpty && !liveStreamId.isEmpty {
            let result: Result<(String?, String?, Date?), YTError> = await withUnsafeContinuation { continuation in
                YTLiveRequest.getLiveBroadcast(broadcastId: broadcastId) { result in
                    switch result {
                    case .success(let liveBroadcast):
                        YTLiveRequest.getLiveStream(liveStreamId, completion: { result in
                            switch result {
                            case .success(let liveStream):
                                let streamName = liveStream.cdn.ingestionInfo.streamName
                                let streamUrl = liveStream.cdn.ingestionInfo.ingestionAddress
                                let scheduledStartTime = liveBroadcast.snippet.scheduledStartTime ?? Date()
                                LiveLauncher.sharedInstance.youTubeWorker = self
                                LiveLauncher.sharedInstance.delegate = delegate
                                LiveLauncher.sharedInstance.launchBroadcast(broadcast: broadcast, stream: liveStream)
                                continuation.resume(returning: .success((streamName, streamUrl, scheduledStartTime)))
                            case .failure(let error):
                                continuation.resume(returning: .failure(error))
                            }
                        })
                    case .failure(let error):
                        let _error: YTError = .message("\(error.message())/nPlease xheck broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
                        continuation.resume(returning: .failure(_error))
                    }
                }
            }
            switch result {
            case .success(let streamInfo):
                return streamInfo
            case .failure(let error):
                throw error
            }
        } else {
            let _error: YTError = .message("Please check broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
            throw _error
        }
    }
    /**
     Deprecated
     @param
     @return
     */
    public func completeBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void) {
        LiveLauncher.sharedInstance.stopBroadcast()
        Task {
            do {
                // complete – The broadcast is over. YouTube stops transmitting video.
                try await self.completeBroadcastAsync(broadcast)
                completion(true)
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    /**
     @param
     @return
     */
    public func completeBroadcastAsync(_ broadcast: LiveBroadcastStreamModel) async throws {
        LiveLauncher.sharedInstance.stopBroadcast()
        // complete – The broadcast is over. YouTube stops transmitting video.
        try await YTLiveRequest.transitionLiveBroadcastAsync(broadcast.id, broadcastStatus: "complete")
    }
    /**
     deleteAllBroadcastsAsync - async function deleting all broadcasts from the Ussr's account
     @param
     @return
     - throws YTError
     */
    public func deleteAllBroadcastsAsync() async throws {
        let broadcastList = try await getBroadcastListAsync(.all)
        let broadcastIDs = broadcastList.map { $0.id }
        try await deleteBroadcastsAsync(broadcastIDs)
    }
    /**
     deleteBroadcasts - async function deleting broadcasts by IDs
     @param
        broadcastsIDs - array of IDs broadcasts will be deleted
     @return
        true if all broadcasts were deleted successfully
     */
    public func deleteBroadcastsAsync(_ broadcastIDs: [String]) async throws {
        let _deletedIDs = try await withThrowingTaskGroup(of: [String].self,
                                                          returning: [String].self,
                                                          body: { taskGroup in
            for broadcastID in broadcastIDs {
                taskGroup.addTask {
                    do {
                        try await self.deleteBroadcast(id: broadcastID)
                        return [broadcastID]
                    }
                    catch {
                        throw error
                    }
                }
            }
            var _deletedIDs = [String]()
            for try await ids in taskGroup {
                _deletedIDs.append(contentsOf: ids)
            }
            return _deletedIDs
        })
        if _deletedIDs.count != broadcastIDs.count {
            throw YTError.YTMessage(.deleteBroadcast, "Unexpected Error")
        }
    }
    /**
     Delete broadcast by ID
     @param
      id: Broadcast ID
     @return
     */
    public func deleteBroadcast(id: String) async throws {
        try await YTLiveRequest.deleteLiveBroadcast(broadcastId: id)
    }
    /**
     Deprecated. Please use async version
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
        Task {
            do {
                try await YTLiveRequest.transitionLiveBroadcastAsync(broadcast.id, broadcastStatus: toStatus)
                print("The broadcast transitioned to \(toStatus) status!")
                completion(true)
            }
            catch {
                print(error.localizedDescription)
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

    private func getBroadcastList(_ status: YTLiveVideoState, completion:  @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void) {
        Task {
            do {
                let broadcastList = try await getBroadcastListAsync(status)
                completion(.success(broadcastList))
            } catch {
                completion(.failure(error as! YTError))
            }
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
