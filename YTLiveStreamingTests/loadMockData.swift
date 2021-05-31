//
//  loadMockData.swift
//  YTLiveStreamingTests
//
//  Created by Serhii Krotkykh on 26.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation

public enum UTError: Error {
    case message(String)
    case systemMessage(Int, String)

    public func message() -> String {
        switch self {
        case .message(let message):
            return message
        case .systemMessage(let code, let message):
            return "System error: \(code)\n\(message)"
        }
    }
}

struct DecodeData {

    static func load<T: Codable>(_ bundle: Bundle, _ filename: String, as type: T.Type = T.self) -> Result<T, UTError> {
        let data: Data
        guard let file = bundle.url(forResource: filename, withExtension: nil) else {
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
