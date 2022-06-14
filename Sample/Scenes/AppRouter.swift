//
//  AppRouter.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming

let Router = AppDelegate.shared.appRouter

class AppRouter: NSObject {

    enum StroyboadType: String, Iteratable {
        case main = "Main"
        var filename: String {
            return rawValue.capitalized
        }
    }

    func showSignInViewController() {
        DispatchQueue.performUIUpdate {
            DispatchQueue.performUIUpdate {
                if #available(iOS 13.0, *) {
//                    if let window = AppDelegate.shared.window {
//                        let viewController = SwiftUISignInViewController()
//                        self.swuftUiSignInDependencies(viewController)
                        
                        UIStoryboard.main.segueToRootViewController(self.swuftUiSignInDependencies)
                        
//                        window.rootViewController = viewController // ?.present(viewController, animated: false, completion: {})
//                    }
                } else {
                    UIStoryboard.main.segueToRootViewController(self.signInDependencies)
                }
            }
        }
    }

    func showMainViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.sequePushViewController(self.streamingListDependencies)
        }
    }

    // Start Live Video
    func showLiveVideoViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.segueToModalViewController(self.liveVideoDependencies, optional: nil)
        }
    }

    // Start Live Video
    func showYouTubeVideoPlayer(videoId: String) {
        DispatchQueue.performUIUpdate {
            if #available(iOS 13.0, *) {
                // Use the Video player UI designed with using SwiftUI
                if let window = AppDelegate.shared.window {
                    let viewController = SwiftUiVideoPlayerViewController()
                    self.swiftUiVideoPlayerDependencies(viewController, videoId)
                    window.rootViewController?.present(viewController, animated: false, completion: {})
                }
            } else {
                // Use the Video player UI designed with using UIKit
                UIStoryboard.main.segueToModalViewController(self.videoPlayerDependencies, optional: videoId)
            }
        }
    }

    func showNewStreamViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.sequePushViewController(self.newStreamDependencies)
        }
    }
}

// MARK: - Dependencies Injection

extension AppRouter {
    ///
    /// Inject dependecncies in the SignInViewController
    ///
    private func signInDependencies(_ viewController: SignInViewController) {
        viewController.viewModel = signInSetUpViewModelDependencies(viewController)
    }

    private func swuftUiSignInDependencies(_ viewController: SwiftUISignInViewController) {
        viewController.viewModel = signInSetUpViewModelDependencies(viewController)
    }

    private func signInSetUpViewModelDependencies(_ viewController: UIViewController) -> GoogleSignInViewModel {
        let interactor = GoogleSignInInteractor()
        interactor.configurator = GoogleSignInConfigurator()
        interactor.presenter = viewController
        interactor.model = SignInModel()
        return GoogleSignInViewModel(interactor: interactor)
    }

    ///
    /// Inject dependecncies in the StreamListViewController
    ///
    private func streamingListDependencies(_ viewController: StreamListViewController) {
        let interactor = GoogleSignInInteractor()
        let signInModel = SignInModel()
        interactor.configurator = GoogleSignInConfigurator()
        interactor.presenter = viewController
        interactor.model = signInModel
        let googleSession = GoogleSessionManager(interactor)

        let viewModel = StreamListViewModel()
        let dataSource = StreamListDataSource()
        let broadcastsAPI = YTLiveStreaming()
        dataSource.broadcastsAPI = broadcastsAPI
        viewModel.dataSource = dataSource
        viewModel.sessionManager = googleSession

        // Inbound Broadcast
        viewController.output = viewModel
        viewController.input = viewModel
        viewController.userProfile = signInModel
    }

    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func liveVideoDependencies(_ viewController: LFLiveViewController, _ optional: Any?) {
        let viewModel = LiveStreamingViewModel()
        let broadcastsAPI = YTLiveStreaming()

        viewModel.broadcastsAPI = broadcastsAPI
        viewController.viewModel = viewModel
    }
    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func newStreamDependencies(_ viewController: NewStreamViewController) {
        let viewModel = NewStreamViewModel()
        let broadcastsAPI = YTLiveStreaming()

        viewModel.broadcastsAPI = broadcastsAPI
        viewController.viewModel = viewModel
    }
    /// UIKit:
    /// Inject dependecncies in to the VideoPlayerViewController
    ///
    private func videoPlayerDependencies(_ viewController: VideoPlayerViewController, _ optional: Any?) {
        VideoPlayerConfigurator.configure(viewController, optional)
    }
    /// SwiftUI:
    /// Inject dependecncies in to the (SwiftUI version of the VideoPlayerViewController) SwiftUiVideoPlayerViewController
    ///
    private func swiftUiVideoPlayerDependencies(_ viewController: SwiftUiVideoPlayerViewController, _ optional: Any?) {
        SwiftUIVideoPlayerConfigurator.configure(viewController, optional)
    }
}

extension AppRouter {
    func closeModal(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension AppRouter: UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        showSignInViewController()
        return true
    }
}
