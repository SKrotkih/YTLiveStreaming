//
//  GoogleSignInWorker.swift
//  YouTubeLiveVideo
//

import Foundation

class GoogleSignInWorker {

    fileprivate var mClientID: String?
    fileprivate let clientIDkey = "CLIENT_ID"
    
    var googleClientId: String {
        if let clientID = self.mClientID {
            return clientID
        }
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
                if let clientID = plist[clientIDkey] as? String, !clientID.isEmpty {
                    mClientID = clientID
                }
            }
        }
        assert(mClientID != nil, "Please put your Client ID in info.plist as GoogleAPIClientID value")
        return mClientID!
    }
}
