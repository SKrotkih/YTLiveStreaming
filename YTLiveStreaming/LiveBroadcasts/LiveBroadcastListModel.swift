//
//  LiveBroadcastListModel.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//
import Foundation
/**
 Responce body of a list of YouTube broadcasts that match the API request parameters.
  Request:
   GET https://www.googleapis.com/youtube/v3/liveBroadcasts
  Scope:
   https://www.googleapis.com/auth/youtube.readonly
   https://www.googleapis.com/auth/youtube
   https://www.googleapis.com/auth/youtube.force-ssl
 @param
 @return
 */
public struct LiveBroadcastListModel: Codable {
    public let kind: String // "youtube#liveBroadcastListResponse"
    public let etag: String // The Etag of this resource.
    public let nextPageToken: String?    // The token that can be used as the value of the pageToken parameter to retrieve the next page in the result set.
    public let prevPageToken: String?    // The token that can be used as the value of the pageToken parameter to retrieve the previous page in the result set.
    public let pageInfo: PageInfo
    public let items: [LiveBroadcastStreamModel]    // A list of broadcasts that match the request criteria.

    // The pageInfo object encapsulates paging information for the result set.
    public struct PageInfo: Codable {
        public let totalResults: Int    // he total number of results in the result set
        public let resultsPerPage: Int  // The number of results included in the API response.
    }
}
