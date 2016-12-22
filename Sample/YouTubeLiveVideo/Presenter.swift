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

   fileprivate var liveBroadcast: LiveBroadcastStreamModel?
   
   var youTubeWorker: YTLiveStreaming!
   var parentViewController: UIViewController!

   fileprivate var viewController: LFLiveViewController!
   
   func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel, completed: @escaping (Bool) -> Void) {
      self.liveBroadcast = liveBroadcast
      
      print("Watch the live video: https://www.youtube.com/watch?v=\(liveBroadcast.id)")
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let viewController = storyboard.instantiateViewController(withIdentifier: "LFLiveViewController") as? LFLiveViewController {
         self.viewController = viewController
         self.viewController.output = self
         self.parentViewController.present(self.viewController, animated: false, completion: {
            completed(true)
         })
      } else {
         completed(false)
      }
   }
   
   fileprivate func dismissVideoStreamViewController() {
      DispatchQueue.main.async {
         self.parentViewController.dismiss(animated: true, completion: {
         })
      }
   }
   
}

// MARK: Live stream publishing output protocol

extension Presenter: YouTubeLiveVideoOutput {
   
   func startPublishing(completed: @escaping (String?, String?) -> Void) {
      guard let broadcast = self.liveBroadcast else {
         assert(false, "Need Broadcast object for starting live video!")
         return
      }
      youTubeWorker.startBroadcast(broadcast, delegate: self, completion: { streamName, streamUrl, scheduledStartTime in
         if let streamName = streamName, let streamUrl = streamUrl, let scheduledStartTime = scheduledStartTime {
            self.viewController.scheduledStartTime = scheduledStartTime as NSDate?
            completed(streamUrl, streamName)
         }
      })
   }
   
   func finishPublishing() {
      guard let broadcast = self.liveBroadcast else {
         self.dismissVideoStreamViewController()
         return
      }
      youTubeWorker.completeBroadcast(broadcast, completion: { success in
         self.dismissVideoStreamViewController()
      })
   }
   
   func cancelPublishing() {
      guard let broadcast = self.liveBroadcast else {
         self.dismissVideoStreamViewController()
         return
      }
      youTubeWorker.deleteBroadcast(id: broadcast.id, completion: { success in
         if success {
            print("Broadcast \"\(broadcast.id)\" was deleted!")
         } else {
            Alert.sharedInstance.showOk("Sorry, system detected error while deleting the video.", message: "You can try to delete it in your YouTube account")
         }
         self.dismissVideoStreamViewController()
      })
   }
}

// MARK: YTLiveStreamingDelegate protocol

extension Presenter: YTLiveStreamingDelegate {
   
   func didTransitionToLiveStatus() {
      self.viewController.showCurrentStatus(currStatus: "● LIVE")
   }
   
   func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
      if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
         let text = "status: \(broadcastStatus) [\(streamStatus);\(healthStatus)]"
         self.viewController.showCurrentStatus(currStatus: text)
      }
   }
}
