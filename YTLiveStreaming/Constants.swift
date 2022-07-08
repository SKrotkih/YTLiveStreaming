//
//  Constants.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/28/16.
//  Copyright © 2016 Serhii Krotkykh. All rights reserved.
//

import Foundation

enum Auth {
    static let ClientSecret = ""
    static let AuthorizeURL = "https://accounts.google.com/o/oauth2/auth"
    static let TokenURL = "https://www.googleapis.com/oauth2/v3/token"
    static let RedirectURL = "http://localhost"
}

enum LiveAPI {
    static let BaseURL = "https://www.googleapis.com/youtube/v3"

    static let Resolution = ResolutionValue.p720.rawValue
    static let FrameRate = FrameRateValue.fps60.rawValue
    static let IngestionType = IngestionTypeValue.rtmp.rawValue
}

enum LiveRequest {
    static let MaxResultObjects = 50
}

enum ResolutionValue: String {
    case p1080 = "1080p"
    case p1440 = "1440p"
    case p720 = "720p"
    case p480 = "480p"
    case p360 = "360p"
    case p240 = "240p"
}

enum FrameRateValue: String {
    case fps60 = "60fps"
    case fps30 = "30fps"
}

enum IngestionTypeValue: String {
    case rtmp
    case dash
}
