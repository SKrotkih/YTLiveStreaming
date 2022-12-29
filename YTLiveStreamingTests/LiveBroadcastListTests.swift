//
//  LiveBroadcastListTests.swift
//  YTLiveStreamingTests
//
//  Created by Serhii Krotkykh on 05.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.

@testable import YTLiveStreaming
import XCTest

class LiveBroadcastListTestCase: XCTestCase {

    fileprivate var broadcastListDataProvider: BroadcastListMockDataProvider!

    // MARK: - Class Setup and Teardown

    override func setUp() {
        super.setUp()
        broadcastListDataProvider = BroadcastListMockDataProvider()
    }

    // MARK: - Live Broadcasts Section

    func testLiveBroadcastList() {
        if let model =  broadcastListDataProvider.getBroadcastList() {
            XCTAssertEqual(model.items.count, 3)
        }
    }
}

// MARK: -

private class BroadcastListMockDataProvider {
    func getBroadcastList() -> LiveBroadcastListModel? {
        let bundle = Bundle(for: BroadcastListMockDataProvider.self)
        switch DecodeData.load(bundle, "LiveBroadcastListModel.json", as: LiveBroadcastListModel.self) {
        case .success(let model):
            return model
        case .failure(let error):
            XCTFail("Failed to parse. Error: \(error.message())")
            return nil
        }
    }
}
