//
//  SwiftUiVideoPlayerViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import RxSwift

class SwiftUiVideoPlayerViewController: UIViewController {

    // Dependencies
    @Lateinit var interactor: PlayerInteractor
    @Lateinit var navigateController: NavicationObservable
    @Lateinit var playerView: PlayerViewRepresentable

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        addBodyView()
        subscribeOnActivity()
    }

    private func addBodyView() {
        let bodyView = VideoPlayerBodyView(interactor: interactor,
                                           navigateController: navigateController,
                                             playerView: playerView)
        addSubSwiftUIView(bodyView, to: view)
    }

    private func subscribeOnActivity() {
        navigateController
            .rxViewClosed
            .subscribe(onNext: { [weak self] _ in
                self?.closeView()
            })
            .disposed(by: disposeBag)
    }

    private func closeView() {
        Router.closeModal(viewController: self)
    }
}
