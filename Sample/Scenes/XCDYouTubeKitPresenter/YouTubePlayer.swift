//  YouTubePlayer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import UIKit

struct YouTubePlayer {
    var youtubeVideoPlayer: YouTubeVideoPlayed!

    func playYoutubeID(_ youtubeId: String, viewController: UIViewController) {
        youtubeVideoPlayer.playVideo(youtubeId, viewController: viewController, { result in
            switch result {
            case .success:
                print("Player has finished play video")
            case .failure(let error):
                Alert.showOk("Error", message: error.message())
            }
        })
    }
}
