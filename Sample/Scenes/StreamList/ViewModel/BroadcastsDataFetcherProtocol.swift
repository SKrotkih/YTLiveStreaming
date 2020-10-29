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
    /// Observable data source for Broadcasts List
    ///
    /// - Parameters:
    ///
    /// - Returns:
    var rxData: PublishSubject<[SectionModel]> { get }
    /// send request to load source data for Broadcasts List
    ///
    /// - Parameters:
    ///
    /// - Returns:
    func loadData()
    /// Get Current Broadcast
    ///
    /// - Parameters:
    ///     - index of the Broadcast source data
    ///
    /// - Returns:
    func getCurrent(for index: Int) -> LiveBroadcastStreamModel
    /// Get Completed  Broadcast
    ///
    /// - Parameters:
    ///     - index of the Broadcast source data
    ///
    /// - Returns:
    func getPast(for index: Int) -> LiveBroadcastStreamModel
}
