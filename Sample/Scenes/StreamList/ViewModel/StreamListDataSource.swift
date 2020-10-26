//
//  StreamListDataSource.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

typealias BroadCastStreams = (_ upcoming: [Stream], _ current: [Stream], _ past: [Stream]) -> Void

class StreamListDataSource: NSObject {

    var broadcastsAPI: YTLiveStreaming!

    fileprivate var upcoming = [LiveBroadcastStreamModel]()
    fileprivate var current = [LiveBroadcastStreamModel]()
    fileprivate var past = [LiveBroadcastStreamModel]()

    func upcoming(_ index: Int) -> LiveBroadcastStreamModel {
        assert(index < upcoming.count, "Broadcast index is invalid")
        return self.upcoming[index]
    }
    
    func current(_ index: Int) -> LiveBroadcastStreamModel {
        assert(index < current.count, "Broadcast index is invalid")
        return self.current[index]
    }
    
    func past(_ index: Int) -> LiveBroadcastStreamModel {
        assert(index < past.count, "Broadcast index is invalid")
        return self.past[index]
    }
    
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
            self.broadcastsAPI.getAllBroadcasts { (_, _, _) in
                fetchingGroup.leave()
            }
        })
        fetchingGroup.enter()
        DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
            self.broadcastsAPI.getUpcomingBroadcasts { result in
                switch result {
                case .success(let streams):
                    self.addStreams(.upcoming, streams: streams)
                case .failure(let error):
                    print(error.message())
                }
                fetchingGroup.leave()
            }
        })
        fetchingGroup.enter()
        DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
            self.broadcastsAPI.getLiveNowBroadcasts { result in
                switch result {
                case .success(let streams):
                    self.addStreams(.current, streams: streams)
                case .failure(let error):
                    print(error.message())
                }
                fetchingGroup.leave()
            }
        })
        fetchingGroup.enter()
        DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
            self.broadcastsAPI.getCompletedBroadcasts { result in
                switch result {
                case .success(let streams):
                    self.addStreams(.past, streams: streams)
                case .failure(let error):
                    print(error.message())
                }
            }
        })
        fetchingGroup.notify(queue: DispatchQueue.main) {
            if let completion = self.completionClosure {
                let upcomingStreams = self.upcoming.map {
                    Stream(time: "start: \($0.snipped.publishedAt)", name: "\($0.snipped.title)")
                }
                let currentStreams = self.current.map {
                    Stream(time: "start: \($0.snipped.publishedAt)", name: "\($0.snipped.title)")
                }
                let pastStreams = self.past.map {
                    Stream(time: "start: \($0.snipped.publishedAt)", name: "\($0.snipped.title)")
                }
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
            self.upcoming += broadcasts
        case .current:
            self.current += broadcasts
        case .past:
            self.past += broadcasts
        }
    }
}
