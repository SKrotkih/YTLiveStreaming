//
//  YouTubeInteractor.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 2/11/18.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import YTLiveStreaming

typealias BroadCastStreams = (_ upcoming: [Stream], _ current: [Stream], _ past: [Stream]) -> Void

class YouTubeInteractor: NSObject {
   
   // Dependebcies
   var input: YTLiveStreaming!

   fileprivate var upcoming = [LiveBroadcastStreamModel]()
   fileprivate var current = [LiveBroadcastStreamModel]()
   fileprivate var past = [LiveBroadcastStreamModel]()
   
   private var completionClosure: BroadCastStreams?
   
   private enum StreamType {
      case upcoming
      case current
      case past
   }
   
   func reloadData(_ completion: @escaping BroadCastStreams) {
      self.upcoming.removeAll()
      self.current.removeAll()
      self.past.removeAll()
      completion([], [], [])
      self.loadData(completion)
   }
   
   func loadData(_ completion: @escaping BroadCastStreams) {
      completionClosure = completion
      
      let fetchingGroup = DispatchGroup()
      fetchingGroup.enter()
      DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
         self.input.getUpcomingBroadcasts() { streams in
            self.addStreams(.upcoming, streams: streams)
            
            print("======== 1 ========\n")
            
            fetchingGroup.leave()
         }
      })
      
      fetchingGroup.enter()
      DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
         self.input.getLiveNowBroadcasts() { streams in
            self.addStreams(.current, streams: streams)
            
            print("======== 2 ========\n")
            
            fetchingGroup.leave()
         }
      })
      
      fetchingGroup.enter()
      DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
         self.input.getCompletedBroadcasts() { streams in
            self.addStreams(.past, streams: streams)
            
            print("======== 3 ========\n")
            
            fetchingGroup.leave()
         }
      })
      
      fetchingGroup.notify(queue: DispatchQueue.main) {
         if let completion = self.completionClosure {

            print("======== Finish ==== (\(self.upcoming.count);\(self.current.count);\(self.past.count); )====\n")
            
            let upcomingStreams = self.upcoming.map({Stream(time: "start: \($0.snipped.publishedAt)", name: "\($0.snipped.title)") })
            let currentStreams = self.current.map({Stream(time: "start: \($0.snipped.publishedAt)", name: "\($0.snipped.title)") })
            let pastStreams = self.past.map({Stream(time: "start: \($0.snipped.publishedAt)", name: "\($0.snipped.title)") })
            completion(upcomingStreams, currentStreams, pastStreams)
         }
      }
   }
   
   private func addStreams(_ type: StreamType, streams: [LiveBroadcastStreamModel]?) {
      guard let broadcasts = streams else {
         return
      }
      switch type {
      case .upcoming:
         self.upcoming = self.upcoming + broadcasts
      case .current:
         self.current = self.current + broadcasts
      case .past:
         self.past = self.past + broadcasts
      }
   }
}

// MARK: -

extension YouTubeInteractor {
   
   func getUpcomingBroadcastItem(index: Int) -> LiveBroadcastStreamModel {
      assert(index < upcoming.count, "Broadcast index is invalid")
      return upcoming[index]
   }
   
   func launchLiveStream(section: Int, index: Int, viewController: UIViewController) {
      switch section {
      case 0:
         assert(false, "Incorrect section number")
      case 1:
         let broadcast = self.current[index]
         YouTubePlayer.playYoutubeID(broadcast.id, viewController: viewController)
      case 2:
         let broadcast = self.past[index]
         YouTubePlayer.playYoutubeID(broadcast.id, viewController: viewController)
      default:
         assert(false, "Incorrect section number")
      }
   }
   
   func createBroadcast(_ completion: @escaping (Error?) -> Void) {
      let title = "Live video"
      let description = "Test broadcast video"
      let startDate = Helpers.dateAfter(Date(), after: (hour: 0, minute: 2, second: 0))
      
      self.input.createBroadcast(title, description: description, startTime: startDate, completion: { broadcast in
         if broadcast != nil {
            completion(nil)
         } else {
            let error = NSError(domain: "Something went wrong", code: 440, userInfo: nil)
            completion(error)
         }
      })
   }
}

