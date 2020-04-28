//
//  StreamListDependencies.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

class StreamListDependencies: NSObject {
    
    func configure(_ viewController: StreamListViewController) {
        let signInInteractor = AppDelegate.shared.googleSignIn
        
        viewController.signInInteractor = signInInteractor
        viewController.signInViewModel = GoogleSessionViewModel(viewController: viewController, signInInteractor: signInInteractor)
        let streamListInteractor = LiveStreamingInteractor()
        viewController.streamListViewModel = StreamListViewModel(viewController: viewController, interactor: streamListInteractor)

        
        
        
        
        let worker = YTLiveStreaming()
        let presenter = Presenter()
        let interactor = LiveStreamingInteractor()
        
        interactor.input = worker
        
        presenter.viewController = viewController
        presenter.signinInteractor = signInInteractor
        presenter.output = viewController
        presenter.youTubeWorker = worker
        presenter.interactor = interactor
    }
}

