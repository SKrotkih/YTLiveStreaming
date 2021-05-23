//
//  SwiftUIVideoPlayerConfigurator.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 23.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation

struct SwiftUIVideoPlayerConfigurator {
    static func configure(_ viewController: SwiftUiVideoPlayerViewController, _ optional: Any?) {
        guard let videoId = optional as? String else {
            return
        }
        guard let videoPlayer = VideoPlayer(videoId: videoId) else {
            return
        }
        let navigateController = NavicationObservable()
        viewController.navigateController = navigateController
        viewController.interactor = VideoPlayerInteractor(videoPlayer: videoPlayer)
        viewController.playerView = PlayerViewRepresentable(playerView: videoPlayer.playerView)
    }
}
