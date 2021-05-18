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

    // Start Live Video
    func showLiveVideoViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.segueToModalViewController(liveVideoDependencies, optional: nil)
        }
    }

    // Start Live Video
    func showYouTubeVideoPlayer(videoId: String) {
        DispatchQueue.performUIUpdate {
            if #available(iOS 13.0, *) {
                // Use the Video player UI designed with using SwiftUI
                if let window = AppDelegate.shared.window {
                    let viewController = SwiftUiVideoPlayerViewController()
                    swiftUiVideoPlayerDependencies(viewController, videoId)
                    window.rootViewController?.present(viewController, animated: false, completion: {})
                }
            } else {
                // Use the Video player UI designed with using UIKit
                UIStoryboard.main.segueToModalViewController(videoPlayerDependencies, optional: videoId)
            }
        }
    }

    func showNewStreamViewController() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.sequePushViewController(newStreamDependencies)
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

        // Inbound Broadcast
        viewController.output = viewModel
        viewController.input = viewModel
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
    ///
    /// Inject dependecncies in the (UIKit) VideoPlayerViewController
    ///
    private func videoPlayerDependencies(_ viewController: VideoPlayerViewController, _ optional: Any?) {
        guard let videoId = optional as? String else {
            return
        }
        viewController.interactor = VideoPlayerInteractor(videoId: videoId)
    }
    ///
    /// Inject dependecncies in the (SwiftUI version of the VideoPlayerViewController) SwiftUiVideoPlayerViewController
    ///
    private func swiftUiVideoPlayerDependencies(_ viewController: SwiftUiVideoPlayerViewController, _ optional: Any?) {
        guard let videoId = optional as? String else {
            return
        }
        viewController.interactor = VideoPlayerInteractor(videoId: videoId)
        viewController.playerView = PlayerViewRepresentable()
    }
}

extension AppRouter {
    func closeModal(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
