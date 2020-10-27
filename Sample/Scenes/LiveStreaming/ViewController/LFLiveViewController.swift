//
//  LFLiveViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 11/8/16.
//

import UIKit
import YTLiveStreaming

class LFLiveViewController: UIViewController {
   var viewModel: YouTubeLiveVideoPublisher?
   var scheduledStartTime: NSDate?
   
   @IBOutlet weak var lfView: LFLivePreview!
   @IBOutlet weak var containerView: UIView!
   @IBOutlet weak var beautyButton: UIButton!
   @IBOutlet weak var cameraButton: UIButton!
   @IBOutlet weak var closeButton: UIButton!
   @IBOutlet weak var startLiveButton: UIButton!
   @IBOutlet weak var currentStatusLabel: UILabel!

   override func viewDidLoad() {
      super.viewDidLoad()
      beautyButton.isExclusiveTouch = true
      cameraButton.isExclusiveTouch = true
      closeButton.isExclusiveTouch = true
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      DispatchQueue.main.async {
         self.lfView.prepareForUsing()
      }
   }

   @IBAction func changeCameraPositionButtonPressed(_ sender: Any) {
      lfView.changeCameraPosition()
   }

   @IBAction func changeBeautyButtonPressed(_ sender: Any) {
      beautyButton.isSelected = lfView.changeBeauty()
   }

   @IBAction func onClickPublish(_ sender: Any) {
      if startLiveButton.isSelected {
         startLiveButton.isSelected = false
         startLiveButton.setTitle("Start live broadcast", for: .normal)
         lfView.stopPublishing()
         viewModel?.finishPublishing()
      } else {
         startLiveButton.isSelected = true
         startLiveButton.setTitle("Finish live broadcast", for: .normal)
         viewModel?.startPublishing { streamURL, streamName in
            if let streamURL = streamURL, let streamName = streamName {
               let streamUrl = "\(streamURL)/\(streamName)"
               self.lfView.startPublishing(withStreamURL: streamUrl)
            }
         }
      }
   }

   @IBAction func closeButtonPressed(_ sender: Any) {
      viewModel?.cancelPublishing()
   }

   func showCurrentStatus(currStatus: String) {
      currentStatusLabel.text = currStatus
   }
}
