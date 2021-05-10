//
//  MockBroadcastList.swift
//  LiveEvents
//
//  Created by Сергей Кротких on 09.05.2021.
//  Copyright © 2021 Sergey Krotkih. All rights reserved.
//
import Foundation
import YTLiveStreaming

// MARK: - Get mock data for UI testing

class MockBroadcastList {
    private static let useMocks = true

    static func mockDataIfNeeded(state: YTLiveVideoState, errMessage: String) -> (String?, [LiveBroadcastStreamModel]) {
        if useMocks {
            let data = getMockBroadcastList()
            var broadcastList = [LiveBroadcastStreamModel]()
            broadcastList = data?.items ?? []
            return (nil, broadcastList)
        } else {
            return (errMessage, [])
        }
    }

    private static func getMockBroadcastList() -> LiveBroadcastListModel? {
        let bundle = Bundle(for: MockBroadcastList.self)
        guard let jsonFileURL = bundle.url(forResource: "LiveBroadcastListModel", withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: jsonFileURL)
            let decoder = JSONDecoder()
            let model = try decoder.decode(LiveBroadcastListModel.self, from: data)
            return model
        } catch {
            return nil
        }
    }
}
