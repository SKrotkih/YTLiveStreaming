import UIKit

class YouTubePlayer: NSObject {

   static var youtubePlayerViewController: YoutubePlayerViewController?
   static var youtubePlayerDelegate: PlayerDelegate?
   
   class func playYoutubeID(_ youtubeId: String, viewController: UIViewController) {
      if self.youtubePlayerViewController == nil {
         self.youtubePlayerViewController = YoutubePlayerViewController()
         self.youtubePlayerDelegate = PlayerDelegate()
         self.youtubePlayerViewController!.delegate = youtubePlayerDelegate
      }
      youtubePlayerViewController!.playVideo(youtubeId, viewController: viewController)
   }
}

class PlayerDelegate: YoutubePlayerDelegate {
   func playerDidFinish() {
      
   }
}
