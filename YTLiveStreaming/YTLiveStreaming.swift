//
//  YTLiveStreaming.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

public enum YTLiveVideoState: String {
   case upcoming = "upcoming"
   case active = "active"
   case completed = "completed"
   case all = "all"
}

private let kOrderByPublishedAt = true

public class YTLiveStreaming: NSObject {

}

// MARK: Public methods interface

extension YTLiveStreaming {
   
   public func getUpcomingBroadcasts(_ completion: @escaping ([LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts(.upcoming, completion: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completion: completion)
         } else {
            completion(nil)
         }
      })
   }
   
   public func getLiveNowBroadcasts(_ completion: @escaping ([LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts(.active, completion: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completion: completion)
         } else {
            completion(nil)
         }
      })
   }
   
   public func getCompletedBroadcasts(_ completion: @escaping ([LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts(.completed, completion: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completion: completion)
         } else {
            completion(nil)
         }
      })
   }

   public func getAllBroadcasts(_ completion: @escaping ([LiveBroadcastStreamModel]?, [LiveBroadcastStreamModel]?, [LiveBroadcastStreamModel]?) -> Void) {
      YTLiveRequest.listBroadcasts(.all, completion: { broadcasts in
         if let broadcasts = broadcasts {
            self.fillList(broadcasts, completion: { streams in
               if let streams = streams {
                  var streamsReady = [LiveBroadcastStreamModel]()
                  var streamsLive = [LiveBroadcastStreamModel]()
                  var streamsComplete = [LiveBroadcastStreamModel]()
                  for item in streams {
                     let lifeCycleStatus = item.status.lifeCycleStatus
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
         } else {
            completion(nil, nil, nil)
         }
      })
   }
   
   fileprivate func fillList(_ broadcasts: LiveBroadcastListModel, completion: ([LiveBroadcastStreamModel]?) -> Void) {
      let items = broadcasts.items
      if kOrderByPublishedAt {
         let sortedItems = items.sorted(by: {$0.snipped.publishedAt.compare($1.snipped.publishedAt) == ComparisonResult.orderedDescending})
         completion(sortedItems)
      } else {
         let sortedItems = items.sorted(by: { $0.snipped.scheduledStartTime.compare($1.snipped.scheduledStartTime) == ComparisonResult.orderedDescending })
         completion(sortedItems)
      }
   }
   
   public func createBroadcast(_ title: String, description: String?, startTime: Date, completion: @escaping (LiveBroadcastStreamModel?) -> Void) {
      
      // Create Live broadcast
      let liveStreamDescription = description == nil ? "This stream was created by the YTLiveStreaming iOS framework" : description!
      let liveStreamName = "YTLiveStreaming"
      
      YTLiveRequest.createLiveBroadcast(title, startDateTime: startTime, completion: { liveBroadcastModel in
         if let liveBroadcast = liveBroadcastModel {
            // Create Live stream
            YTLiveRequest.createLiveStream(title, description: liveStreamDescription, streamName: liveStreamName) { liveStream in
               if let liveStream = liveStream {
                  // Bind live stream
                  YTLiveRequest.bindLiveBroadcast(broadcastId: liveBroadcast.id, liveStreamId: liveStream.id, completion: { liveBroadcast in
                     if let liveBroadcast = liveBroadcast {
                        completion(liveBroadcast)
                     } else {
                        completion(nil)
                     }
                  })
               } else {
                  print("Something went wrong with creating a live stream")
                  completion(nil)
               }
            }
         } else {
            print("Something went wrong with creating a broadcast")
            completion(nil)
         }
      })
      
   }

   public func updateBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void) {
      YTLiveRequest.updateLiveBroadcast(broadcast, completion: completion)
   }
   
   public func startBroadcast(_ broadcast: LiveBroadcastStreamModel, delegate: LiveStreamTransitioning, completion: @escaping (String?, String?, Date?) -> Void) {
      let broadcastId = broadcast.id
      let liveStreamId = broadcast.contentDetails.boundStreamId
      if !broadcastId.isEmpty &&  !liveStreamId.isEmpty {
         YTLiveRequest.getLiveBroadcast(broadcastId: broadcastId) { liveBroadcast in
            if let liveBroadcast = liveBroadcast {
               YTLiveRequest.getLiveStream(liveStreamId, completion: { liveStream in
                  if let liveStream = liveStream {
                     
                     let streamName = liveStream.cdn.ingestionInfo.streamName
                     let streamUrl = liveStream.cdn.ingestionInfo.ingestionAddress
                     let scheduledStartTime = liveBroadcast.snipped.scheduledStartTime
                     
                     let sreamId = liveStream.id
                     let monitorStream = liveBroadcast.contentDetails.monitorStream.embedHtml
                     let streamTitle = liveStream.snipped.title
                     
                     print("\n-BroadcastId=\(liveBroadcast.id);\n-Live stream id=\(sreamId); \n-title=\(streamTitle); \n-start=\(scheduledStartTime); \n-STREAM_URL=\(streamUrl)/STREAM_NAME=\(streamName): created!\n-MONITOR_STREAM=\(monitorStream)\n")
                     
                     LiveLauncher.sharedInstance.youTubeWorker = self
                     LiveLauncher.sharedInstance.delegate = delegate
                     LiveLauncher.sharedInstance.launchBroadcast(broadcast: broadcast, stream: liveStream)
                     completion(streamName, streamUrl, scheduledStartTime)
                  }
               })
            } else {
               print("Something went wrong. Please xheck broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
               completion(nil, nil, nil)
            }
         }
      } else {
         print("Something went wrong. Please xheck broadcast.youtubeId. It has to contain broadcast Id and live stream Id")
         completion(nil, nil, nil)
      }
   }
   
   public func completeBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void) {
      LiveLauncher.sharedInstance.stopBroadcast()
      // complete – The broadcast is over. YouTube stops transmitting video.
      YTLiveRequest.transitionLiveBroadcast(broadcast.id, broadcastStatus: "complete", completion: { liveBroadcast in
         if let _ = liveBroadcast {
            completion(true)
         } else {
            completion(false)
         }
      })
      
   }

   public func deleteBroadcast(id: String, completion: @escaping (Bool) -> Void) {
      YTLiveRequest.deleteLiveBroadcast(broadcastId: id, completion: completion)
   }

   public func transitionBroadcast(_ broadcast: LiveBroadcastStreamModel, toStatus: String, completion: @escaping (Bool) -> Void) {
         // complete – The broadcast is over. YouTube stops transmitting video.
         // live – The broadcast is visible to its audience. YouTube transmits video to the broadcast's monitor stream and its broadcast stream.
         // testing – Start testing the broadcast. YouTube transmits video to the broadcast's monitor stream.
         YTLiveRequest.transitionLiveBroadcast(broadcast.id, broadcastStatus: toStatus, completion: { liveBroadcast in
            if let _ = liveBroadcast {
               completion(true)
               print("Our broadcast in the \(toStatus) status!")
            } else {
               completion(false)
            }
         })
   }
   
   public func getStatusBroadcast(_ broadcast: LiveBroadcastStreamModel, stream: LiveStreamModel, completion: @escaping (String?, String?, String?) -> Void) {
      YTLiveRequest.getLiveBroadcast(broadcastId: broadcast.id, completion: { broadcast in
         if let broadcast = broadcast {
            let broadcastStatus = broadcast.status.lifeCycleStatus
            
            //            Valid values for this property are:
            //            abandoned – This broadcast was never started.
            //            complete – The broadcast is finished.
            //            created – The broadcast has incomplete settings, so it is not ready to transition to a live or testing status, but it has been created and is otherwise valid.
            //            live – The broadcast is active.
            //            liveStarting – The broadcast is in the process of transitioning to live status.
            //            ready – The broadcast settings are complete and the broadcast can transition to a live or testing status.
            //            reclaimed – This broadcast has been reclaimed.
            //            revoked – This broadcast was removed by an admin action.
            //            testStarting – The broadcast is in the process of transitioning to testing status.
            //            testing – The broadcast is only visible to the partner.
            
            YTLiveRequest.getLiveStream(stream.id, completion: { liveStream in
               if let liveStream = liveStream {
                  //            Valid values for this property are:
                  //            active – The stream is in active state which means the user is receiving data via the stream.
                  //            created – The stream has been created but does not have valid CDN settings.
                  //            error – An error condition exists on the stream.
                  //            inactive – The stream is in inactive state which means the user is not receiving data via the stream.
                  //            ready – The stream has valid CDN settings.
                  let streamStatus = liveStream.status.streamStatus
                  
                  //            Valid values for this property are:
                  //            good – There are no configuration issues for which the severity is warning or worse.
                  //            ok – There are no configuration issues for which the severity is error.
                  //            bad – The stream has some issues for which the severity is error.
                  //            noData – YouTube's live streaming backend servers do not have any information about the stream's health status.
                  let healthStatus = liveStream.status.healthStatus.status
                  completion(broadcastStatus, streamStatus, healthStatus)
               } else {
                  completion(nil, nil, nil)
               }
            })
         } else {
            completion(nil, nil, nil)
         }
      })
   }

   public func transitionBroadcastToLiveState(liveBroadcast: LiveBroadcastStreamModel, liveState: @escaping (Bool) -> Void) {
      self.transitionBroadcast(liveBroadcast, toStatus: "live", completion: { success in
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
      })
   }
   
   public func isYouTubeAvailable() -> Bool {
      return GoogleOAuth2.sharedInstance.isAccessTokenPresented
   }
}

// MARK: Private methods

extension YTLiveStreaming {
   
   fileprivate func deleteAllBroadcasts(_ completion: @escaping (Bool) -> Void) {
      YTLiveRequest.listBroadcasts(.all, completion: { broadcastList in
         if let broadcastList = broadcastList {
            let items = broadcastList.items
            self.deleteBroadcast(items, index: 0, completion: completion)
         } else {
            completion(false)
         }
      })
   }
   
   fileprivate func deleteBroadcast(_ items: [LiveBroadcastStreamModel], index: Int, completion: @escaping (Bool) -> Void) {
      if index < items.count {
         let item = items[index]
         let broadcastId = item.id
         self.deleteBroadcast(id: broadcastId, completion: { success in
            if success {
               print("Broadcast \"\(broadcastId)\" deleted!")
            }
            self.deleteBroadcast(items, index: index + 1, completion: completion)
         })
      } else {
         completion(true)
      }
   }
}

// MARK Tests

extension YTLiveStreaming {
   
   func testUpdateLiveStream() {
      let liveStreamId = "0"
      let title = "Live Stream"
      let format = "1080p"    // 1080p 1440p 240p 360p 480p 720p
      let ingestionType = "rtmp" // dash rtmp
      YTLiveRequest.updateLiveStream(liveStreamId, title: title, format: format, ingestionType: ingestionType, completion: { success in
         
         if success {
            print("All right")
         } else {
            print("Something went wrong")
         }
         
      })
   }
   
}

