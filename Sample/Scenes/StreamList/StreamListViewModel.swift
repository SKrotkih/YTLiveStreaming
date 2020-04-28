//
//  StreamListViewModel.swift
//  YouTubeLiveVideo
//

import Foundation
import RxSwift

class StreamListViewModel {
    
    var interactor: LiveStreamingInteractor!
    unowned var viewController: StreamListViewController!

    private let disposeBag = DisposeBag()
    
    init(viewController: StreamListViewController, interactor: LiveStreamingInteractor) {
        self.viewController = viewController
        self.interactor = interactor
    }
    
    func bindEvents() {
        viewController.addNewStreamButton
            .rx
            .tap
            .debounce(.milliseconds(Constants.UI.debounce), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.creadeBroadcast()
            }).disposed(by: disposeBag)
    }
    
    func reloadData() {
        interactor.reloadData() { upcoming, current, past  in
            self.viewController.present(content: (upcoming, current, past))
        }
    }
    
    fileprivate func loadData() {
        interactor.loadData() { (upcoming, current, past) in
            self.viewController.present(content: (upcoming, current, past))
        }
    }
    
    fileprivate func creadeBroadcast() {
        Alert.sharedInstance.showConfirmCancel("YouTube Live Streaming API", message: "You realy want to create a new Live broadcast video?", onConfirm: {
            self.interactor.createBroadcast() { error in
                if let error = error {
                    Alert.sharedInstance.showOk("Error", message: error.localizedDescription)
                } else {
                    Alert.sharedInstance.showOk("Done", message: "Please, refresh the table after pair seconds (pull down)")
                }
            }
        })
    }
    
    func launchStream(section: Int, index: Int) {
        interactor.launchLiveStream(section: section, index: index, viewController: viewController)
    }
}
