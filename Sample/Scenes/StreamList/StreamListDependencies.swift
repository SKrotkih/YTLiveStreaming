//
//  StreamListDependencies.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

class StreamListDependencies: NSObject {

    func configure(_ viewController: StreamListViewController) {
        let signInInteractor = AppDelegate.shared.googleSignIn

        // Sign In
        viewController.signInInteractor = signInInteractor
        viewController.signInViewModel = GoogleSessionViewModel(viewController: viewController,
                                                                signInInteractor: signInInteractor)

        // Inbound Broadcast
        let streamListInteractor = InboundBroadcastPresenter()
        let viewModel = StreamListViewModel(viewController: viewController, interactor: streamListInteractor)
        viewController.streamListViewModel = viewModel

        // Outbound Broadcast
        let presenter = OutboundBroadcastPresenter()
        presenter.viewController = viewController
        presenter.interactor = streamListInteractor
    }
}
