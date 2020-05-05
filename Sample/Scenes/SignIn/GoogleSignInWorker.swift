//
//  GoogleSignInWorker.swift
//  YouTubeLiveVideo
//

import Foundation

class GoogleSignInWorker {

    fileprivate var _clientID: String?
    fileprivate let clientIDkey = "CLIENT_ID"
    
    var googleClientId: String {
        if let _ = _clientID {
        } else if let clientID = getInfo(clientIDkey) {
            _clientID = clientID
        } else {
            assert(false, "Please put your Client ID in info.plist as GoogleAPIClientID value")
        }
        return _clientID!
    }
    
    private func getInfo(_ key: String) -> String? {
        if let plist = getPlist("Info"), let info = plist[key] as? String, !info.isEmpty {
            return info
        } else if let plist = getPlist("Config"), let info = plist[key] as? String, !info.isEmpty {
            return info
        } else {
            return nil
        }
    }

    private func getPlist(_ name: String) -> NSDictionary? {
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as NSDictionary?
        } else {
            return nil
        }
    }
}
