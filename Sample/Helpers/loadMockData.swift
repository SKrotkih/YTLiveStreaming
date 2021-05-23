//
//  loadMockData.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 26.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation

struct DecodeData {

    static func loadMockData<T: Codable>(_ filename: String, as type: T.Type = T.self) -> Result<T, LVError> {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return .failure(.message("Couldn't find \(filename) in main bundle."))
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            return .failure(.message("Couldn't load \(filename) from main bundle:\n\(error)"))
        }

        do {
            let decoder = JSONDecoder()
            return .success(try decoder.decode(T.self, from: data))
        } catch {
            return .failure(.message("Couldn't parse \(filename) as \(T.self):\n\(error)"))
        }
    }
}
