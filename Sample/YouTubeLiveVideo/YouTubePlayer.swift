import UIKit

class YouTubePlayer: NSObject {

   fileprivate var youtubePlayerViewController: YoutubePlayerViewController?
   
   class var sharedInstance: YouTubePlayer {
      struct SingletonWrapper {
         static let sharedInstance = YouTubePlayer()
      }
      return SingletonWrapper.sharedInstance;
   }
   
   func playYoutubeID(_ youtubeId: String, viewController: UIViewController) {
      if self.youtubePlayerViewController == nil {
         self.youtubePlayerViewController = YoutubePlayerViewController()
         self.youtubePlayerViewController!.delegate = self
      }
      youtubePlayerViewController!.playVideo(youtubeId, viewController: viewController)
   }
}

extension YouTubePlayer: YoutubePlayerDelegate {
   
   func playerDidFinish() {
      
   }
   
}
