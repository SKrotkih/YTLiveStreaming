//
//  LiveBroadcastListTests.swift
//  LiveEventsTests
//
//  Created by Сергей Кротких on 05.05.2021.
//  Copyright © 2021 Sergey Krotkih. All rights reserved.
//

@testable import LiveEvents
import SwiftyJSON
import XCTest
import YTLiveStreaming

class LiveBroadcastListTestCase: XCTestCase {

    fileprivate var broiadCastListDataProvider: BroadcastListMockDataProvider!

    // MARK: - Class Setup and Teardown

    override func setUp() {
        super.setUp()
        broiadCastListDataProvider = BroadcastListMockDataProvider()
    }

    // MARK: - Live Broadcasts Section

    func testLiveBroadcastList() {
        if let model =  broiadCastListDataProvider.getBroadcastList() {
            XCTAssertEqual(model.items.count, 3)
        }
    }
}

// MARK: -

private class BroadcastListMockDataProvider {
    func getBroadcastList() -> LiveBroadcastListModel? {
        let bundle = Bundle(for: BroadcastListMockDataProvider.self)
        guard let jsonFileURL = bundle.url(forResource: "LiveBroadcastListModel", withExtension: "json") else {
            XCTFail("Couldn't find LiveBroadcastListModel.json")
            return nil
        }
        do {
            let data = try Data(contentsOf: jsonFileURL)
            let decoder = JSONDecoder()
            let model = try decoder.decode(LiveBroadcastListModel.self, from: data)
            print(model)
            return model
        } catch {
            XCTFail("Failed to parse. Error: \(error)")
            return nil
        }
    }
}
