//  XCDYouTubeVideoPlayer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import UIKit
import XCDYouTubeKit
import AVKit

/**
    YouTube Video Player
    Test ID: "9bZkp7q19f0"
 */
class XCDYouTubeVideoPlayer: NSObject, YouTubeVideoPlayed {
    struct YTVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }

    private var completion: ((Result<Void, LVError>) -> Void)?

    func playVideo(_ youtubeId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void) {
        self.completion = completion
        let playerViewController = AVPlayerViewController()
        viewController.present(playerViewController, animated: true, completion: nil)
        XCDYouTubeClient.default().getVideoWithIdentifier(youtubeId) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs,
               let streamURL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
                streamURLs[YTVideoQuality.hd720] ??
                streamURLs[YTVideoQuality.medium360] ??
                streamURLs[YTVideoQuality.small240] {
                playerViewController?.player = AVPlayer(url: streamURL)
                playerViewController?.player?.play()
                 playerViewController?.delegate = self
            } else {
                viewController.dismiss(animated: true, completion: nil)
                let errorMessage = error?.localizedDescription ?? "Faled gettng Youtube Video via ID"
                self.completion?(.failure(.message(errorMessage)))
            }
        }
    }
}

// MARK: - AVPlayerViewControllerDelegate methods

extension XCDYouTubeVideoPlayer: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.completion?(.success(Void()))
    }
}
