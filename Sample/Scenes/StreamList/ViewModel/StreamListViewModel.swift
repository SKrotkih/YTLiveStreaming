//
//  StreamListViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming
import RxSwift

enum VideoPlayerType {
    case oldVersionForIos8
    case AVPlayerViewController
    case VideoPlayerViewController
}

class StreamListViewModel: MainViewModelOutput {
    // Default value of the used video player
    private static let playerType: VideoPlayerType = .VideoPlayerViewController

    @Lateinit var dataSource: BroadcastsDataFetcher
    @Lateinit var sessionManager: SessionManager

    var rxError = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    private var videoPlayer = YouTubePlayer()

    var playerFactory: YouTubeVideoPlayed {
        switch StreamListViewModel.playerType {
        case .oldVersionForIos8:
            return XCDYouTubeVideoPlayer8()
        case .AVPlayerViewController:
            return XCDYouTubeVideoPlayer()
        case .VideoPlayerViewController:
            return YTVideoPlayer()
        }
    }

    func didOpenViewAction() {
        configure()
        dataSource.loadData()
    }

    func didSignOutAction() {
        sessionManager.signOut()
    }

    func didCloseViewAction() {
        Router.showSignInViewController()
    }

    private func configure() {
        rxData
            .subscribe(onNext: { data in
                var message = ""
                data.forEach { item in
                    if let errorMessage = item.error {
                        message += errorMessage + "\n"
                    }
                }
                if !message.isEmpty {
                    self.rxError.onNext(message)
                }
            }).disposed(by: disposeBag)
    }

    func createBroadcast() {
        Router.showNewStreamViewController()
    }

    func didLaunchStreamAction(indexPath: IndexPath, viewController: UIViewController) {
        videoPlayer.youtubeVideoPlayer = playerFactory

        switch indexPath.section {
        case 0:
            assert(false, "Incorrect section number")
        case 1:
            let broadcast = dataSource.getCurrent(for: indexPath.row)
            videoPlayer.playYoutubeID(broadcast.id, viewController: viewController)
        case 2:
            let broadcast = dataSource.getPast(for: indexPath.row)
            videoPlayer.playYoutubeID(broadcast.id, viewController: viewController)
        default:
            assert(false, "Incorrect section number")
        }
    }
}

// MARK: - MainViewModelInput protocol implementation

extension StreamListViewModel: MainViewModelInput {
    var rxSignOut: PublishSubject<Bool> {
        return sessionManager.rxSignOut
    }

    var rxData: PublishSubject<[SectionModel]> {
        return self.dataSource.rxData
    }
}
