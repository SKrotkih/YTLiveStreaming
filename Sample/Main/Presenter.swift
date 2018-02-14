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

   // Dependebcies
   var viewController: ViewController!
   var output: ViewController!
   var signinInteractor: GoogleConnect!
   
   var youTubeWorker: YTLiveStreaming!
   var interactor: YouTubeInteractor!
   
   fileprivate var liveBroadcast: LiveBroadcastStreamModel?
   fileprivate var liveViewController: LFLiveViewController!
   
   func launchShow() {
      launchSignIn()
   }

   func presentUserInfo() {
      if let userInfo = signinInteractor.currentUserInfo {
         output.presentUserInfo(connected: true, userInfo: userInfo)
         loadData()
      } else {
         output.presentUserInfo(connected: false, userInfo: "")
      }
   }

   func launchReloadData() {
      reloadData()
   }
   
   func launchSignIn() {
      signinInteractor.signIn(with: viewController)
   }

   func launchSignOut() {
      signinInteractor.signOut()
      presentUserInfo()
   }
   
   func launchLiveStream(section: Int, index: Int) {
      if section == 0 {
         let broadcast = interactor.getUpcomingBroadcastItem(index: index)
         self.startBroadcast(broadcast, completed: { success in
            if success == false {
               Alert.sharedInstance.showOk("Failed attempt", message: "Can't create broadcast")
            }
         })
      } else {
         interactor.launchLiveStream(section: section, index: index, viewController: viewController)
      }
   }
   
   func startActivity() {
      viewController.startActivity()
   }
   
   func stopActivity() {
      viewController.stopActivity()
   }
}

// MARK: - Privete methods

extension Presenter {

   fileprivate func reloadData() {
      guard signinInteractor.isConnected else {
         return
      }
      interactor.reloadData() { upcoming, current, past  in
         self.output.present(content: (upcoming, current, past))
      }
   }
   
   fileprivate func loadData() {
      guard signinInteractor.isConnected else {
         return
      }
      interactor.loadData() { (upcoming, current, past) in
         self.output.present(content: (upcoming, current, past))
      }
   }
}

// MARK: -

extension Presenter {
   
   func createBroadcast(_ completion: @escaping (Error?) -> Void) {
      interactor.createBroadcast(completion)
   }
   
   func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel, completed: @escaping (Bool) -> Void) {
      self.liveBroadcast = liveBroadcast
      
      print("Watch the live video: https://www.youtube.com/watch?v=\(liveBroadcast.id)")
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let liveViewController = storyboard.instantiateViewController(withIdentifier: "LFLiveViewController") as? LFLiveViewController {
         self.liveViewController = liveViewController
         self.liveViewController.output = self
         self.viewController.present(self.liveViewController, animated: false, completion: {
            completed(true)
         })
      } else {
         completed(false)
      }
   }
   
   fileprivate func dismissVideoStreamViewController() {
      DispatchQueue.main.async {
         self.viewController.dismiss(animated: true, completion: {
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
            self.liveViewController.scheduledStartTime = scheduledStartTime as NSDate?
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
      self.liveViewController.showCurrentStatus(currStatus: "● LIVE")
   }
   
   func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
      if let broadcastStatus = broadcastStatus, let streamStatus = streamStatus, let healthStatus = healthStatus {
         let text = "status: \(broadcastStatus) [\(streamStatus);\(healthStatus)]"
         self.liveViewController.showCurrentStatus(currStatus: text)
      }
   }
}
