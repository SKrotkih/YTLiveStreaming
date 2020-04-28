//
//  Dependencies.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

class Dependencies: NSObject {
    
    func configure(_ viewController: StreamListViewController) {
        
        let worker = YTLiveStreaming()
        let presenter = Presenter()
        let interactor = YouTubeInteractor()
        
        let signInInteractor = AppDelegate.shared.googleSignIn
        
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

