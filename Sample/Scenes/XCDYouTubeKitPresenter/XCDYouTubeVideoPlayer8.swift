//  XCDYouTubeVideoPlayer8.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import UIKit
import XCDYouTubeKit

/**
    YouTube Video Player whish used for the iOS 8
 */
class XCDYouTubeVideoPlayer8: YouTubeVideoPlayed {
    var completion: ((Result<Void, LVError>) -> Void)?
    var videoPlayerViewController: XCDYouTubeVideoPlayerViewController?

    func playVideo(_ youtubeId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void) {
        guard self.videoPlayerViewController == nil else {
            return
        }
        self.completion = completion
        let playerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: youtubeId)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayerPlaybackDidFinish(_:)),
                                               name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                               object: playerViewController.moviePlayer)
        viewController.present(playerViewController, animated: true) { [weak self] in
            guard let `self` = self else { return }
            self.videoPlayerViewController = nil
        }
        self.videoPlayerViewController = playerViewController
    }

    @objc func moviePlayerPlaybackDidFinish(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                                  object: nil)
        if  let userInfo = notification.userInfo,
            let objectInfo = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey],
            let finishReason = (objectInfo as AnyObject).int32Value as? MPMovieFinishReason {
            switch finishReason {
            case .playbackError:
                if let error = userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey] as? String {
                    self.completion?(.failure(.message(error)))
                }
            case .playbackEnded, .userExited:
                self.completion?(.success(Void()))
            }
        }
    }
}
