//
//  AppRouter.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation
import YTLiveStreaming

let Router = AppDelegate.shared.appRouter

struct AppRouter {

    enum StroyboadType: String, Iteratable {
        case main = "Main"
        var filename: String {
            return rawValue.capitalized
        }
    }

    func showSignInViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.segueToRootViewController(self.signInDependencies)
        }
    }

    func showMainViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.sequePushViewController(self.streamingListDependencies)
        }
    }

    func showLiveVideoViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.segueToModalViewController(self.liveVideoDependencies)
        }
    }
}

// MARK: - Dependencies Injection

extension AppRouter {
    ///
    /// Inject dependecncies in the GoogleSignInViewController
    ///
    private func signInDependencies(_ viewController: GoogleSignInViewController) {
        let interactor = AppDelegate.shared.googleSignIn
        let viewModel = GoogleSignInViewModel(interactor: interactor)
        viewController.viewModel = viewModel
    }

    ///
    /// Inject dependecncies in the StreamListViewController
    ///
    private func streamingListDependencies(_ viewController: StreamListViewController) {

        let signInInteractor = AppDelegate.shared.googleSignIn
        let googleSession = GoogleSessionManager(signInInteractor)

        let viewModel = StreamListViewModel()
        let dataSource = StreamListDataSource()
        let broadcastsAPI = YTLiveStreaming()
        dataSource.broadcastsAPI = broadcastsAPI
        viewModel.dataSource = dataSource
        viewModel.sessionManager = googleSession
        viewModel.broadcastsAPI = broadcastsAPI

        // Inbound Broadcast
        viewController.output = viewModel
        viewController.input = viewModel
    }

    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func liveVideoDependencies(_ viewController: LFLiveViewController) {
        let viewModel = LiveStreamingViewModel()
        let broadcastsAPI = YTLiveStreaming()

        viewModel.broadcastsAPI = broadcastsAPI
        viewController.viewModel = viewModel
    }
}
