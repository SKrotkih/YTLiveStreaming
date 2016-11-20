//
//  LiveLauncher.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 11/13/16.
//

import Foundation

@objc public protocol YTLiveStreamingDelegate: class {
   @objc optional func didTransitionToLiveStatus()
   @objc optional func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?)
}

class LiveLauncher: NSObject {

   let AskStatusStreamFrequencyInSeconds = 5.0
   fileprivate var liveBroadcast: LiveBroadcastStreamModel?
   fileprivate var liveStream: LiveStreamModel?
   
   var delegate: YTLiveStreamingDelegate?
   var youTubeWorker: YTLiveStreaming?
   
   fileprivate var timer: Timer?
   
   private override init() {
      
   }
   
   class var sharedInstance: LiveLauncher {
      struct Singleton {
         static let instance = LiveLauncher()
      }
      return Singleton.instance
   }

   func launchBroadcast(broadcast: LiveBroadcastStreamModel?, stream: LiveStreamModel?) {
      self.liveBroadcast = broadcast
      self.liveStream = stream
      self.startTimerForChekingStatusStream()
   }

   func stopBroadcast() {
      timer?.invalidate()
      timer = nil
   }
   
   fileprivate func startTimerForChekingStatusStream() {
      timer?.invalidate()
      timer = Timer(timeInterval: AskStatusStreamFrequencyInSeconds, target: self, selector: #selector(liveVideoStatusRequestTickTimer), userInfo: nil, repeats: true)
      RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
      liveVideoStatusRequestTickTimer()
   }
   
   func liveVideoStatusRequestTickTimer() {
      statusRequest() { liveStatus in
         if liveStatus {
            self.delegate?.didTransitionToLiveStatus?()
         } else {
            self.transitionToLive() { success in
               if success {
                  self.delegate?.didTransitionToLiveStatus?()
               }
            }
         }
      }
   }
   
   fileprivate func statusRequest(completed: @escaping (Bool) -> Void) {
      guard let liveBroadcast = self.liveBroadcast else {
         return
      }
      guard let liveStream = self.liveStream else {
         return
      }
      self.youTubeWorker?.getStatusBroadcast(liveBroadcast, stream: liveStream, completed: { (broadcastStatus, streamStatus, healthStatus) in
         if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
            if broadcastStatus == "live" || broadcastStatus == "liveStarting" {
               completed(true)
            } else {
               self.delegate?.didTransitionToStatus?(broadcastStatus: broadcastStatus, streamStatus: streamStatus, healthStatus: healthStatus)
               completed(false)
            }
         }
      })
   }
   
   fileprivate func transitionToLive(completed: @escaping (Bool) -> Void) {
      guard let liveBroadcast = self.liveBroadcast else {
         return
      }
      self.youTubeWorker?.transitionBroadcastToLiveState(liveBroadcast: liveBroadcast, liveState: completed)
   }
}
