//
//  AppRouter.swift
//  YouTubeLiveVideo
//

import Foundation
import YTLiveStreaming

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
        let viewModel = GoogleSignInViewModel(viewController: viewController)
        viewController.viewModel = viewModel
    }
    
    ///
    /// Inject dependecncies in the StreamListViewController
    ///
    private func streamingListDependencies(_ viewController: StreamListViewController) {

        let signInInteractor = AppDelegate.shared.googleSignIn
        let signInViewModel = GoogleSessionViewModel(signInInteractor)
        viewController.signInViewModel = signInViewModel
        
        let viewModel = StreamListViewModel()
        let dataSource = StreamListDataSource()
        let broadcastsAPI = YTLiveStreaming()
        dataSource.broadcastsAPI = broadcastsAPI
        viewModel.dataSource = dataSource
        viewModel.broadcastsAPI = broadcastsAPI
        
        // Inbound Broadcast
        viewController.viewModel = viewModel
    }
    
    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func liveVideoDependencies(_ viewController: LFLiveViewController) {
        let viewModel = LiveStreamingViewModel()
        let broadcastsAPI = YTLiveStreaming()

        viewModel.broadcastsAPI = broadcastsAPI
        viewModel.liveViewController = viewController
        viewController.viewModel = viewModel
    }
}
