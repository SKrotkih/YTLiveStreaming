//
//  YouTubeVideoPlayed.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 23.03.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation

protocol YouTubeVideoPlayed {
    func playVideo(_ youtubeId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void)
}
