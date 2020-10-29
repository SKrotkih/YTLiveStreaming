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
    func getCurrent(for index: Int) -> LiveBroadcastStreamModel
    func getPast(for index: Int) -> LiveBroadcastStreamModel
}
