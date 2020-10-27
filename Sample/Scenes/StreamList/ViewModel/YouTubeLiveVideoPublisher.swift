//
//  YouTubeLiveVideoPublisher.swift
//  YouTubeLiveVideo
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation

protocol YouTubeLiveVideoPublisher: class {
   func startPublishing(completed: @escaping (String?, String?) -> Void)
   func finishPublishing()
   func cancelPublishing()
}
