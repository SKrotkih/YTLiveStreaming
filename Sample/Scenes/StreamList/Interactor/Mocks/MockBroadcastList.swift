//
//  MockBroadcastList.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 09.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//
import Foundation
import YTLiveStreaming

// MARK: - Get mock data for UI testing

class MockBroadcastList {
    private static let useMocks = true

    static func mockDataIfNeeded(state: YTLiveVideoState, errMessage: String) -> (String?, [LiveBroadcastStreamModel]) {
        if useMocks {
            switch DecodeData.loadMockData("LiveBroadcastListModel.json", as: LiveBroadcastListModel.self) {
            case .success(let model):
                print(model)
                var broadcastList = [LiveBroadcastStreamModel]()
                broadcastList = model.items
                return (nil, broadcastList)
            case .failure(let error):
                return (error.message(), [])
            }
        } else {
            return (errMessage, [])
        }
    }
}
