//
//  UpdateLiveStreamsBody.swift
//  YTLiveStreaming
//
//  Created by Serhii Krotkykh on 10/24/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//
import Foundation

// MARK: - Insert LiveStreams. Request Body

/**
 Insert liveStream. Request Body
 Request
  POST https://www.googleapis.com/youtube/v3/liveStreams
 Scope
  https://www.googleapis.com/auth/youtube
  https://www.googleapis.com/auth/youtube.force-ssl
 @param
 @return
 **/
struct CreateLiveStreamBody: Codable {

    struct Snipped: Codable {
        var title: String
        var description: String

        init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    struct ContentDetails: Codable {
        let isReusable: Bool
    }

    struct Cdn: Codable {
        var frameRate: String
        var ingestionType: String
        var resolution: String

        init(streamName: String) {
            frameRate = LiveAPI.FrameRate
            ingestionType = LiveAPI.IngestionType
            resolution = LiveAPI.Resolution
        }
    }

    let snippet: Snipped
    let cdn: Cdn
    let contentDetails: ContentDetails
    
    init(title: String, description: String, streamName: String, isReusable: Bool) {
        snippet = Snipped(title: title, description: description)
        cdn = Cdn(streamName: streamName)
        contentDetails = ContentDetails(isReusable: isReusable)
    }
}

// MARK: - Update LiveStreams. Request Body

/**
  Update liveStream. Request Body
  Request
    PUT https://www.googleapis.com/youtube/v3/liveStreams
  Scope
   https://www.googleapis.com/auth/youtube
   https://www.googleapis.com/auth/youtube.force-ssl
 @param
 @return
 **/
struct UpdateLiveStreamBody: Codable {
    struct Snipped: Codable {
        var title: String
        var description: String

        init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

    struct Cdn: Codable {
        let frameRate: String
        let ingestionType: String
        let resolution: String
    }

    let id: String
    let snippet: Snipped
    let cdn: Cdn

    init(id: String, title: String, description: String, frameRate: String, ingestionType: String, resolution: String) {
        self.id = id
        snippet = Snipped(title: title, description: description)
        cdn = Cdn(frameRate: frameRate, ingestionType: ingestionType, resolution: resolution)
    }
}
