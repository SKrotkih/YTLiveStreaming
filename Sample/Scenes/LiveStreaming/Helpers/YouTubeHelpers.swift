//
//  Thumbnails.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation

struct YouTubeHelpers {
    static func thumbnail(_ youtubeId: String) -> UIImage? {
        let thumbnailFile = "\(youtubeId).jpg"
        if let thumbnailUrl = URL(string: "https://www.youtube.com/watch?v=\(thumbnailFile)"),
           let imageData = try? Data(contentsOf: thumbnailUrl) {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
}
