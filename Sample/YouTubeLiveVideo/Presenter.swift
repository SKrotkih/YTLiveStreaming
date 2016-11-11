//
//  Presenter.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import YTLiveStreaming

class Presenter: NSObject {
   
   fileprivate var timer: Timer?
   fileprivate var livestreamId: String?
   
   fileprivate var liveBroadcast: LiveBroadcastStreamModel?
   fileprivate var liveStream: LiveStreamModel?
   
   fileprivate var isLiveVideo: Bool = false
   
   var liveStreaming: YTLiveStreaming!
   var viewController: UIViewController!

   fileprivate var liveViewController: LFLiveViewController!
   
}

// MARK: Live stream publishing

extension Presenter: VideoStreamViewControllerDelegate {
   
   func showVideoStreamViewController(_ liveStream: LiveStreamModel, liveBroadcast: LiveBroadcastStreamModel, completed: @escaping () -> Void) {
      self.liveBroadcast = liveBroadcast
      self.liveStream = liveStream
      
      let streamName = liveStream.cdn.ingestionInfo.streamName
      let streamUrl = liveStream.cdn.ingestionInfo.ingestionAddress
      let scheduledStartTime = liveBroadcast.snipped.scheduledStartTime
      
      let sreamId = liveStream.id
      let monitorStream = liveBroadcast.contentDetails.monitorStream.embedHtml
      let streamTitle = liveStream.snipped.title
      
      print("\n-BroadcastId=\(liveBroadcast.id);\n-Live stream id=\(sreamId); \n-title=\(streamTitle); \n-start=\(scheduledStartTime); \n-STREAM_URL=\(streamUrl)/STREAM_NAME=\(streamName): created!\n-MONITOR_STREAM=\(monitorStream)\n")
      print("Watch the live video: https://www.youtube.com/watch?v=\(liveBroadcast.id)")
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let liveViewController = storyboard.instantiateViewController(withIdentifier: "LFLiveViewController") as? LFLiveViewController {
         self.liveViewController = liveViewController
         self.liveViewController.delegate = self
         self.liveViewController.scheduledStartTime = scheduledStartTime as NSDate?
         self.liveViewController.livebroadcast = liveBroadcast
         self.liveViewController.streamURL = streamUrl
         self.liveViewController.streamName = streamName
         self.viewController.present(self.liveViewController, animated: false, completion: {
            completed()
         })
      } else {
         completed()
      }
   }

   fileprivate func dismissVideoStreamViewController() {
      DispatchQueue.main.async {
         self.viewController.dismiss(animated: true, completion: {
         })
      }
   }
   
   func startPublishing(broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void) {
      self.isLiveVideo = false
      self.startChekingStreamStatusTimer()
      completed(true)
   }
   
   func finishPublishing(broadcast: LiveBroadcastStreamModel?, completed: @escaping (Bool) -> Void) {
      stopChekingStreamStatusTimer()
      
      if let broadcast = broadcast {
         liveStreaming.completeBroadcast(broadcast, completed: { success in
            if success {
               print("Broadcast completed!")
            }
            self.dismissVideoStreamViewController()
            completed(true)
         })
      } else {
         self.dismissVideoStreamViewController()
         completed(false)
      }
      completed(true)
   }
   
   func cancelPublishing(broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void) {
      if broadcast == nil {
         self.dismissVideoStreamViewController()
      } else if let liveBroadcast = self.liveBroadcast {
         liveStreaming.deleteBroadcast(id: liveBroadcast.id, completed: { success in
            if success {
               print("Broadcast \"\(liveBroadcast.id)\" was deleted!")
            } else {
               Alert.sharedInstance.showOk("Sorry, system error while delete video", message: "You can try to do it in your YouTube account")
            }
            self.dismissVideoStreamViewController()
         })
      }
   }
   
   fileprivate func startChekingStreamStatusTimer() {

      let timerIntervalInSec = 5.0
      
      timer?.invalidate()
      timer = Timer(timeInterval: timerIntervalInSec, target: self, selector: #selector(requestBroadcastStatus), userInfo: nil, repeats: true)
      RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
      requestBroadcastStatus()
   }
   
   fileprivate func stopChekingStreamStatusTimer() {
      timer?.invalidate()
      timer = nil
   }
   
   func requestBroadcastStatus() {
      guard let liveBroadcast = self.liveBroadcast else {
         return
      }
      guard let liveStream = self.liveStream else {
         return
      }
      
      self.liveStreaming.getStatusBroadcast(liveBroadcast, stream: liveStream, completed: { (broadcastStatus, streamStatus, healthStatus) in
         if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {

            if broadcastStatus == "live" || broadcastStatus == "liveStarting" {
               self.liveViewController.showCurrentStatus(currStatus: "● LIVE   ")
            } else {
               let text = "status: \(broadcastStatus) [\(streamStatus);\(healthStatus)]"
               
               if text == "active" {
                  print("active")
               }
               
               self.liveViewController.showCurrentStatus(currStatus: text)
               
               self.liveStreaming.transitionBroadcast(liveBroadcast, toStatus: "live", completed: { success in
                  if success {
                     print("Transition to the LIVE status was made successfully")
                     self.isLiveVideo = true
                  } else {
                     print("Failed transition to the LIVE status!")
                     self.isLiveVideo = false
                     self.liveStreaming.transitionBroadcast(liveBroadcast, toStatus: "testing", completed: { success in
                        if success {
                           print("We in the testing status!")
                        }
                     })
                  }
               })
            }
            
         }
      })
   }

}
