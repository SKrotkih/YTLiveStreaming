//
//  InboundBroadcastPresenter.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

typealias BroadCastStreams = (_ upcoming: [Stream], _ current: [Stream], _ past: [Stream]) -> Void

class InboundBroadcastPresenter: NSObject {
    
    fileprivate let incomingBroadcastWorker = YTLiveStreaming()
    
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
            self.incomingBroadcastWorker.getUpcomingBroadcasts() { streams in
                self.addStreams(.upcoming, streams: streams)
                fetchingGroup.leave()
            }
        })
        
        fetchingGroup.enter()
        DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
            self.incomingBroadcastWorker.getLiveNowBroadcasts() { streams in
                self.addStreams(.current, streams: streams)
                fetchingGroup.leave()
            }
        })
        
        fetchingGroup.enter()
        DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
            self.incomingBroadcastWorker.getCompletedBroadcasts() { streams in
                self.addStreams(.past, streams: streams)
                fetchingGroup.leave()
            }
        })
        
        fetchingGroup.notify(queue: DispatchQueue.main) {
            if let completion = self.completionClosure {
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

extension InboundBroadcastPresenter {
    
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
        
        self.incomingBroadcastWorker.createBroadcast(title, description: description, startTime: startDate, completion: { broadcast in
            if broadcast != nil {
                completion(nil)
            } else {
                let error = NSError(domain: "Something went wrong", code: 440, userInfo: nil)
                completion(error)
            }
        })
    }
}

