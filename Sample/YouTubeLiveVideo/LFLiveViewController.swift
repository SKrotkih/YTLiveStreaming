//
//  LFLiveViewController.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 11/8/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import YTLiveStreaming

protocol VideoStreamViewControllerDelegate: class {
   func startPublishing(broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void)
   func finishPublishing(broadcast: LiveBroadcastStreamModel?, completed: @escaping (Bool) -> Void)
   func cancelPublishing(broadcast: LiveBroadcastStreamModel?, completed: (Bool) -> Void)
}

class LFLiveViewController: UIViewController {

   var delegate: VideoStreamViewControllerDelegate?
   var livebroadcast: LiveBroadcastStreamModel?
   var scheduledStartTime: NSDate?
   
   var streamURL: String?
   var streamName: String?
   
   private var timer: Timer?
   
   @IBOutlet weak var lfView: LFLivePreview!
   
   private var publishButton: UIButton!
   private var currentFPSLabel: UILabel!
   private var currentStatusLabel: UILabel!
   private var timeLeftLabel: UILabel!
   private var closeButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()

//      currentFPSLabel = UILabel()
//      currentFPSLabel.textColor = UIColor.white
//      currentFPSLabel.backgroundColor = UIColor.clear
//      currentFPSLabel.text = ""
//      view.addSubview(currentFPSLabel)
//      
//      currentStatusLabel = UILabel()
//      currentStatusLabel.textColor = UIColor.white
//      currentStatusLabel.backgroundColor = UIColor.clear
//      currentStatusLabel.text = ""
//      currentStatusLabel.textAlignment = .right
//      view.addSubview(currentStatusLabel)
//      
//      timeLeftLabel = UILabel()
//      timeLeftLabel.textColor = UIColor.white
//      timeLeftLabel.backgroundColor = UIColor.clear
//      timeLeftLabel.text = ""
//      timeLeftLabel.textAlignment = .center
//      view.addSubview(timeLeftLabel)
      
//      closeButton = UIButton()
//      closeButton.setImage(UIImage(named: "close_button"), for: .normal)
//      closeButton.addTarget(self, action: #selector(LFLiveViewController.closeButtonPressed(sender:)), for: .touchUpInside)
//      view.addSubview(closeButton)
      
//      publishButton = UIButton()
//      publishButton.backgroundColor = UIColor.red
//      publishButton.setTitle("●", for: .normal)
//      publishButton.layer.masksToBounds = true
//      publishButton.addTarget(self, action: #selector(LFLiveViewController.onClickPublish(sender:)), for: .touchUpInside)
//      view.addSubview(publishButton)
    }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      if let streamURL = streamURL, let streamName = streamName {
         let streamUrl = "\(streamURL)/\(streamName)"
         DispatchQueue.main.async {
            
            print("\(self.lfView.frame)")
            
            self.lfView.prepareFor(using: streamUrl)
         }
      } else {
         print("Error")
      }
      
   }
   
   override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      
//      let buttonSize: CGFloat = 44.0
//      let boundsWidth = view.bounds.width
//      closeButton.frame = CGRect(x: (boundsWidth - 30.0) / 2.0, y: 15, width: 30.0, height: 30.0)
//      publishButton.frame = CGRect(x: (boundsWidth - buttonSize) / 2.0, y: view.bounds.height - (buttonSize + 20.0), width: buttonSize, height: buttonSize)
//      
//      var x: CGFloat = 0.0
//      currentFPSLabel.frame = CGRect(x: x, y: 50, width: 60, height: 30)
//      x += 60.0
//      currentStatusLabel.frame = CGRect(x: x, y: 50, width: boundsWidth - (x + 20.0), height: 30)
//      timeLeftLabel.frame = CGRect(x: 0.0, y: view.bounds.height - (buttonSize + 20.0 + 40.0 + 10.0), width: boundsWidth, height: 40)
   }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   func closeButtonPressed(sender: AnyObject) {
      
   }
   
   func onClickPublish(sender: AnyObject) {
      
   }
 
   func showCurrentStatus(currStatus: String) {
      print("STAUS=\(currStatus)")
   }
   
   
}

extension LFLiveViewController {
   
}
