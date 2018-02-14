//
//  Dependencies.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import YTLiveStreaming

class Dependencies: NSObject {
   
   func configure(_ viewController: ViewController) {
      
      let worker = YTLiveStreaming()
      let presenter = Presenter()
      let interactor = YouTubeInteractor()
      let signInInteractor = AppDelegate.shared.googleSignIn
      
      signInInteractor.presenter = presenter
      
      interactor.input = worker
      
      viewController.input = worker
      viewController.presenter = presenter
      viewController.eventHandler = presenter
      
      presenter.viewController = viewController
      presenter.signinInteractor = signInInteractor
      presenter.output = viewController
      presenter.youTubeWorker = worker
      presenter.interactor = interactor
   }
}

