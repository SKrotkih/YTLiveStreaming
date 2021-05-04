//  XCDYouTubeVideoPlayer8.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//
import UIKit

class YTVideoPlayer: YouTubeVideoPlayed {
    var completion: ((Result<Void, LVError>) -> Void)?

    func playVideo(_ youtubeId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void) {

        self.completion = completion

        let playerViewController = YTPlayerViewController(youTubeId: youtubeId)
        viewController.present(playerViewController, animated: true, completion: nil)

    }
}
