//
//  LiveBroadcastListModel.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct LiveBroadcastListModel: Codable {
    public let etag: String
    public let items: [LiveBroadcastStreamModel]
    public let kind: String
    public let pageInfo: PageInfo

    public struct PageInfo: Codable {
        public let resultsPerPage: Int
        public let totalResults: Int
    }
}
