//
//  VideoPlayerConfigurator.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 23.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation

struct VideoPlayerConfigurator {
    static func configure(_ viewController: VideoPlayerViewController, _ optional: Any?) {
        guard let videoId = optional as? String else {
            return
        }
        guard let videoPlayer = VideoPlayer(videoId: videoId) else {
            return
        }
        viewController.interactor = VideoPlayerInteractor(videoPlayer: videoPlayer)
    }
}
