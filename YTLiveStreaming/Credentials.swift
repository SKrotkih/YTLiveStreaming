//
//  Credentials.swift
//  YTLiveStreaming
//

import Foundation

final class Credentials: NSObject {
    private static var _clientID: String?
    private static var _APIkey: String?
    private static let plistKeyClientID = "CLIENT_ID"
    private static let plistKeyAPIkey = "API_KEY"

    static var clientID: String {
        if Credentials._clientID == nil {
            Credentials._clientID = getInfo(plistKeyClientID)
        }
        assert(Credentials._clientID != nil, "Please put your Client ID to the Info.plist!")
        return Credentials._clientID!
    }

    static var APIkey: String {
        if Credentials._APIkey == nil {
            Credentials._APIkey = getInfo(plistKeyAPIkey)
        }
        assert(Credentials._APIkey != nil, "Please put your APY key to the Info.plist!")
        return Credentials._APIkey!
    }

    static private func getInfo(_ key: String) -> String? {
        if let plist = getPlist("Info"), let info = plist[key] as? String, !info.isEmpty {
            return info
        } else if let plist = getPlist("Config"), let info = plist[key] as? String, !info.isEmpty {
            return info
        } else {
            return nil
        }
    }

    static private func getPlist(_ name: String) -> NSDictionary? {
        var plist: NSDictionary?
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            if let content = NSDictionary(contentsOfFile: path) as NSDictionary? {
                plist = content
            }
        }
        return plist
    }
}
