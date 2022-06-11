//
//  GoogleClientId.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import GoogleSignIn

protocol SignInConfigurator {
    var signInConfig: GIDConfiguration { get }
}

class GoogleSignInConfigurator: SignInConfigurator {

    var signInConfig: GIDConfiguration {
        return GIDConfiguration(clientID: clientID)
    }

    lazy fileprivate var clientID: String = {
        return getClentID()
    }()

    private func getClentID() -> String {
        let key = "CLIENT_ID"
        if let plist = getPlist("Info"), let id = plist[key] as? String, !id.isEmpty {
            return id
        } else if let plist = getPlist("Config"), let id = plist[key] as? String, !id.isEmpty {
            return id
        } else {
            assert(false, "Please put your Client ID in info.plist as GoogleAPIClientID value")
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
