//
//  LiveLauncher.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 11/13/16.
//

import Foundation

@objc public protocol LiveStreamTransitioning: class {
   @objc optional func didTransitionToLiveStatus()
   @objc optional func didTransitionTo(broadcastStatus: String?, streamStatus: String?, healthStatus: String?)
}

class LiveLauncher: NSObject {

   let AskStatusStreamFrequencyInSeconds = 3.0
   fileprivate var liveBroadcast: LiveBroadcastStreamModel?
   fileprivate var liveStream: LiveStreamModel?
   fileprivate var _isLiveStreaming: Bool = false
   
   var delegate: LiveStreamTransitioning?
   var youTubeWorker: YTLiveStreaming?
   
   fileprivate var timer: Timer?
   
   var isLiveStreaming: Bool {
      set {
         if newValue != _isLiveStreaming {
            _isLiveStreaming = newValue
            if _isLiveStreaming {
               self.delegate?.didTransitionToLiveStatus?()
            }
         }
      }
      get {
         return _isLiveStreaming
      }
   }
   
   private override init() {
      
   }
   
   class var sharedInstance: LiveLauncher {
      struct Singleton {
         static let instance = LiveLauncher()
      }
      return Singleton.instance
   }

   func launchBroadcast(broadcast: LiveBroadcastStreamModel?, stream: LiveStreamModel?) {
      liveBroadcast = broadcast
      liveStream = stream
      isLiveStreaming = false
      startTimerForChekingStatusStream()
   }

   func stopBroadcast() {
      timer?.invalidate()
      timer = nil
   }
   
   fileprivate func startTimerForChekingStatusStream() {
      timer?.invalidate()
      timer = Timer(timeInterval: AskStatusStreamFrequencyInSeconds, target: self, selector: #selector(liveVideoStatusRequestTickTimer), userInfo: nil, repeats: true)
    RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
      liveVideoStatusRequestTickTimer()
   }
   
   @objc func liveVideoStatusRequestTickTimer() {
      statusRequest() { liveStatus in
         if liveStatus {
            self.isLiveStreaming = true
         } else {
            self.transitionToLive() { success in
               if success {
                  self.isLiveStreaming = true
               }
            }
         }
      }
   }
   
   fileprivate func statusRequest(completion: @escaping (Bool) -> Void) {
      guard let liveBroadcast = self.liveBroadcast else {
         return
      }
      guard let liveStream = self.liveStream else {
         return
      }
      self.youTubeWorker?.getStatusBroadcast(liveBroadcast, stream: liveStream, completion: { (broadcastStatus, streamStatus, healthStatus) in
         if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
            if broadcastStatus == "live" || broadcastStatus == "liveStarting" {
               completion(true)
            } else {
               self.delegate?.didTransitionTo?(broadcastStatus: broadcastStatus, streamStatus: streamStatus, healthStatus: healthStatus)
               completion(false)
            }
         }
      })
   }
   
   fileprivate func transitionToLive(completion: @escaping (Bool) -> Void) {
      guard let liveBroadcast = self.liveBroadcast else {
         return
      }
      self.youTubeWorker?.transitionBroadcastToLiveState(liveBroadcast: liveBroadcast, liveState: completion)
   }
}
