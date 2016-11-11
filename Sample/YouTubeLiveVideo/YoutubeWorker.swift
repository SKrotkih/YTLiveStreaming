import UIKit

class YoutubeWorker: NSObject {

   fileprivate var youtubePlayerViewController: YoutubePlayerViewController?
   
   class var sharedInstance: YoutubeWorker {
      struct SingletonWrapper {
         static let sharedInstance = YoutubeWorker()
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

extension YoutubeWorker: YoutubePlayerDelegate {
   
   func playerDidFinish() {
      
   }
   
}
