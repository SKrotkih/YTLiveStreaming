//
//  AppRouter.swift
//  YouTubeLiveVideo
//

import Foundation

struct AppRouter {
    
    enum StroyboadType: String, Iteratable {
        case main = "Main"
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    func launchSignInViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.launchAsRootViewController(self.signInDependencies)
        }
    }
    
    func showStreamingList() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.launchAsRootViewController(self.streamingListDependencies)
        }
    }

    ///
    /// Inject dependecncies in the GoogleSignInViewController
    ///
    func signInDependencies(_ viewController: GoogleSignInViewController) {
        let viewModel = GoogleSignInViewModel(viewController: viewController)
        viewController.viewModel = viewModel
    }
    
    func streamingListDependencies(_ viewController: StreamListViewController) {
        let signInInteractor = AppDelegate.shared.googleSignIn
        let signInViewModel = GoogleSessionViewModel(signInInteractor)
        viewController.signInViewModel = signInViewModel
        
        let viewModel = StreamListViewModel()
        let streamListInteractor = InboundBroadcastPresenter()
        viewModel.interactor = streamListInteractor
        
        // Inbound Broadcast
        viewController.viewModel = viewModel
        
        // Outbound Broadcast
        let presenter = OutboundBroadcastPresenter()
        presenter.viewController = viewController
        presenter.interactor = streamListInteractor
    }
}
