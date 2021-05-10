//  YTVideoPlayer.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

class YTVideoPlayer: YouTubeVideoPlayed {
    var completion: ((Result<Void, LVError>) -> Void)?
    func playVideo(_ youtubeId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void) {
        self.completion = completion
        Router.showYouTubeVideoPlayer(videoId: youtubeId)
    }
}
