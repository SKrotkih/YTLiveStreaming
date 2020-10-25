//
//  StreamListViewModel.swift
//  YouTubeLiveVideo
//

import Foundation
import RxSwift

class StreamListViewModel {

    var interactor: InboundBroadcastPresenter!

    private let disposeBag = DisposeBag()

    func loadData(_ completion: @escaping (Result<([Stream], [Stream], [Stream]), LVError>) -> Void) {
        interactor.loadData { (upcomingStreams, currentStreams, pastStreams)  in
            completion(.success((upcomingStreams, currentStreams, pastStreams)))
        }
    }

    func reloadData(_ completion: @escaping (Result<([Stream], [Stream], [Stream]), LVError>) -> Void) {
        interactor.reloadData { (upcomingStreams, currentStreams, pastStreams)  in
            completion(.success((upcomingStreams, currentStreams, pastStreams)))
        }
    }

    func creadeBroadcast() {
        Alert.sharedInstance.showConfirmCancel("YouTube Live Streaming API",
                                               message: "You realy want to create a new Live broadcast video?",
                                               onConfirm: {
            self.interactor.createBroadcast { error in
                if let error = error {
                    Alert.sharedInstance.showOk("Error", message: error.localizedDescription)
                } else {
                    Alert.sharedInstance.showOk("Done",
                                                message: "Please, refresh the table after pair seconds (pull down)")
                }
            }
        })
    }

    func launchStream(section: Int, index: Int, viewController: UIViewController) {
        interactor.launchLiveStream(section: section, index: index, viewController: viewController)
    }
}
