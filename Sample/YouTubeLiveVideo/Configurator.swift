//
//  Configurator.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/24/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit
import YTLiveStreaming

class Configurator: NSObject {
   
   func configure(_ viewController: ViewController) {
      
      let worker = YTLiveStreaming()
      let presenter = Presenter()
      
      viewController.input = worker
      viewController.presenter = presenter
      
      presenter.viewController = viewController
      presenter.liveStreaming = worker
   }
}

