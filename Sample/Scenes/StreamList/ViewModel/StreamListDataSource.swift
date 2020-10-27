//
//  StreamListDataSource.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit
import YTLiveStreaming
import RxDataSources
import RxSwift

struct SectionModel {
    var model: String
    var items: [LiveBroadcastStreamModel]
}

extension SectionModel: SectionModelType {
    init(original: SectionModel, items: [LiveBroadcastStreamModel]) {
        self = original
        self.items = items
    }
}

class StreamListDataSource: NSObject {

    var broadcastsAPI: BroadcastsAPI!
    
    var rxData: PublishSubject<[SectionModel]> = PublishSubject<[SectionModel]>()
    
    private var data = [
        SectionModel(model: "Upcoming", items: []),
        SectionModel(model: "Live now", items: []),
        SectionModel(model: "Completed", items: [])
    ]

    func upcoming(_ index: Int) -> LiveBroadcastStreamModel {
        assert(index < data[0].items.count, "Broadcast index is invalid")
        return self.data[0].items[index]
    }
    
    func current(_ index: Int) -> LiveBroadcastStreamModel {
        assert(index < data[1].items.count, "Broadcast index is invalid")
        return self.data[1].items[index]
    }
    
    func past(_ index: Int) -> LiveBroadcastStreamModel {
        assert(index < data[2].items.count, "Broadcast index is invalid")
        return self.data[2].items[index]
    }
    
    func loadData() {
        for i in 0..<data.count {
            data[i].items.removeAll()
        }
        rxData.onNext(self.data)
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
                    self.data[0].items += streams
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
                    self.data[1].items += streams
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
                    self.data[2].items += streams
                case .failure(let error):
                    print(error.message())
                }
            }
        })
        fetchingGroup.notify(queue: DispatchQueue.main) {
            self.rxData.onNext(self.data)
        }
    }
}
