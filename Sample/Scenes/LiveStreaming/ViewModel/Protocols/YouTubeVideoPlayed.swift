//
//  YouTubeVideoPlayed.swift
//  LiveEvents
//
//  Created by Сергей Кротких on 23.03.2021.
//  Copyright © 2021 Sergey Krotkih. All rights reserved.
//

import Foundation

protocol YouTubeVideoPlayed {
    func playVideo(_ youtubeId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void)
}
