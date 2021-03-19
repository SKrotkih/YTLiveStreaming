//
//  GoogleUser.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation
import GoogleSignIn

struct GoogleUser: Codable {
    let userId: String
    let idToken: String
    let fullName: String
    let givenName: String
    let familyName: String
    let email: String

    init?(_ user: GIDGoogleUser) {
        if let userId = user.userID,
           let idToken = user.authentication.idToken {
            self.userId = userId
            self.idToken = idToken
            fullName = user.profile.name ?? ""
            givenName = user.profile.givenName ?? ""
            familyName = user.profile.familyName ?? ""
            email = user.profile.email ?? ""
        } else {
            return nil
        }
    }

    static var storageKeyName: String {
        return String(describing: self)
    }

    static var name: String? {
        let user: GoogleUser? = LocalStorage.restoreObject(key: storageKeyName)
        return user?.fullName
    }

    static var token: String? {
        let user: GoogleUser? = LocalStorage.restoreObject(key: storageKeyName)
        return user?.idToken
    }

    static func signIn(as user: GIDGoogleUser) -> Bool {
        if let user = GoogleUser(user) {
            return LocalStorage.saveObject(user, key: storageKeyName)
        } else {
            print("Server Error: User data is wrong")
            return false
        }
    }

    static func signOut() {
        LocalStorage.removeObject(key: storageKeyName)
    }
}
