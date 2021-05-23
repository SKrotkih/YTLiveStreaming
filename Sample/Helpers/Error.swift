//  Error.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation

enum LVError: Error {
    case message(String)
    case systemMessage(Int, String)

    func message() -> String {
        switch self {
        case .message(let message):
            return message
        case .systemMessage(let code, let message):
            return "System error: \(code)\n\(message)"
        }
    }

    func printDescription(_ comment: String? = nil,
                          _ file: String = #file,
                          _ function: String = #function,
                          _ line: Int = #line) {
        #if DEBUG
        print("💣 |E|\(file.fileName)):\(function):\(line):[\(Thread.current)]\(comment ?? ""):\(self.message())")
        #endif
    }
}
