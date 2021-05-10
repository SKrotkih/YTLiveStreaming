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
            UIStoryboard.main.segueToModalViewController(youTubeVideoPlayer, optional: videoId)
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
    /// Inject dependecncies in the VideoPlayerViewController
    ///
    private func youTubeVideoPlayer(_ viewController: VideoPlayerViewController, _ optional: Any?) {
        if let videoId = optional as? String {
            viewController.videoId = videoId
        }
    }
}
