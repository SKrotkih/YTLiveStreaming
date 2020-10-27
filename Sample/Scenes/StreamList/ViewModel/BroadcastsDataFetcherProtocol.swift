//
//  BroadcastsDataFetcherProtocol.swift
//  YouTubeLiveVideo
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation
import YTLiveStreaming
import RxSwift

protocol BroadcastsDataFetcher {
    var rxData: PublishSubject<[SectionModel]> { get set }
    func loadData()
    func current(_ index: Int) -> LiveBroadcastStreamModel
    func past(_ index: Int) -> LiveBroadcastStreamModel
}
