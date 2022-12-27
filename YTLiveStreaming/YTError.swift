//
//  YTError.swift
//  YTLiveStreaming
//

import Foundation

public enum YTErrorType: Int {
    case deleteBroadcast
}

public enum YTError: Error {
    case message(String)
    case systemMessage(Int, String)
    case YTMessage(YTErrorType, String)

    public func message() -> String {
        switch self {
        case .message(let message):
            return message
        case .systemMessage(let code, let message):
            return "System error: \(code)\n\(message)"
        case .YTMessage(let code, let message):
            switch code {
            case .deleteBroadcast:
                return "Delete broadcast failure:\n\(message)"
            }
        }
    }
}
