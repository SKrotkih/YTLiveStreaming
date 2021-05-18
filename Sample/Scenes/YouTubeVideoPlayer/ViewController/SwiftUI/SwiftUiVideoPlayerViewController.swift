//
//  SwiftUiVideoPlayerViewController.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import UIKit

class SwiftUiVideoPlayerViewController: UIViewController {

    // Dependencies
    var interactor: PlayerInteractor!
    var playerView: PlayerViewRepresentable!

    override func viewDidLoad() {
        super.viewDidLoad()

        addSwiftUIView()
    }

    private func addSwiftUIView() {
        let bodyView = VideoPlayerBodyView(interactor: interactor,
                                             playerView: playerView)
        addSubSwiftUIView(bodyView, to: view)
        // TODO: Subscribe on close view press button
    }

    func closeView() {
        Router.closeModal(viewController: self)
    }
}
