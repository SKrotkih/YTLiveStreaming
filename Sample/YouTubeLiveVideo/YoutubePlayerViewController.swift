import UIKit
import XCDYouTubeKit

protocol YoutubePlayerDelegate {
   func playerDidFinish()
}

class YoutubePlayerViewController: UIViewController {
   var delegate: YoutubePlayerDelegate?
   var videoPlayerViewController: XCDYouTubeVideoPlayerViewController?
   fileprivate var currentRotation = "P"
   
   func playVideo(_ youtubeId: String, viewController: UIViewController) {
      self.videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: youtubeId)
      NotificationCenter.default.addObserver(self, selector: #selector(YoutubePlayerViewController.moviePlayerPlaybackDidFinish(_:)),
                                                       name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish,
                                                       object: self.videoPlayerViewController!.moviePlayer)
      viewController.present(self.videoPlayerViewController!, animated: true) {
      }
   }
   
   @objc func moviePlayerPlaybackDidFinish(_ notification: Notification) {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
      if let finishReason: MPMovieFinishReason = (notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]! as AnyObject).int32Value as? MPMovieFinishReason {
         if finishReason == .playbackError {
            if let error = notification.userInfo![XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey] {
               print(error)
            }
         }
      }
      delegate?.playerDidFinish()
   }
   
   func thumbnail(_ youtubeId: String) -> UIImage {
      let imageData = try? Data(contentsOf: URL(string: "https://www.youtube.com/watch?v=\(youtubeId).jpg")!)
      return UIImage(data: imageData!)!
   }
}
