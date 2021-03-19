//
//  StreamListViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation
import YTLiveStreaming
import RxSwift

class StreamListViewModel: MainViewModelOutput {
    private static let useYTPlayerOldVersion = false

    var dataSource: BroadcastsDataFetcher!
    var broadcastsAPI: BroadcastsAPI!
    var sessionManager: SessionManager!

    var rxError = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    private var videoPlayer = YouTubePlayer()

    var playerFactory: YouTubeVideoPlayed {
        if StreamListViewModel.useYTPlayerOldVersion {
            return XCDYouTubeVideoPlayer8()
        } else {
            return XCDYouTubeVideoPlayer()
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

    func didCreateBroadcastAction() {
        Alert.showConfirmCancel("YouTube Live Streaming API",
                                message: "You realy want to create a new Live broadcast video?",
                                onConfirm: {
                                    self.createBroadcast { error in
                                        if let error = error {
                                            Alert.showOk("Error",
                                                         message: error.localizedDescription)
                                        } else {
                                            Alert.showOk("Done",
                                                         message: "Please, refresh the table after pair seconds (pull down)")
                                        }
                                    }
                                }
        )
    }

    private func createBroadcast(title: String = "Live video",
                                 description: String = "Test broadcast video",
                                 _ completion: @escaping (Error?) -> Void) {
        let startDate = Helpers.dateAfter(Date(), hour: 0, minute: 2, second: 0)
        self.broadcastsAPI.createBroadcast(title, description: description, startTime: startDate, completion: { result in
            switch result {
            case .success(let broadcast):
                print("Broadcast \(broadcast.snipped.title) was created successfully")
                completion(nil)
            case .failure(let error):
                switch error {
                case .systemMessage(let code, let message):
                    let err = NSError(domain: message, code: code, userInfo: nil)
                    completion(err)
                default:
                    let err = NSError(domain: error.message(), code: -1, userInfo: nil)
                    completion(err)
                }
            }
        })
    }

    func didLaunchStreamAction(indexPath: IndexPath, viewController: UIViewController) {
        videoPlayer.youtubeVideoPlayer = playerFactory

        switch indexPath.section {
        case 0:
            assert(false, "Incorrect section number")
        case 1:
            let broadcast = self.dataSource.getCurrent(for: indexPath.row)
            videoPlayer.playYoutubeID(broadcast.id, viewController: viewController)
        case 2:
            let broadcast = self.dataSource.getPast(for: indexPath.row)
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
