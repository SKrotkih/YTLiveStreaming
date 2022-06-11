//
//  SignInModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 6/14/22.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//

import Foundation
import GoogleSignIn

// User profile information

struct GoogleUser: Codable {
    let userId: String
    let idToken: String
    let accessToken: String?
    let fullName: String
    let givenName: String
    let familyName: String
    let profilePicUrl: URL?
    let email: String

    init?(_ user: GIDGoogleUser) {
        if let userId = user.userID,
           let idToken = user.authentication.idToken {
            self.userId = userId
            self.idToken = idToken
            accessToken = user.authentication.accessToken
            fullName = user.profile?.name ?? ""
            givenName = user.profile?.givenName ?? ""
            familyName = user.profile?.familyName ?? ""
            profilePicUrl = user.profile?.imageURL(withDimension: 320)
            email = user.profile?.email ?? ""
        } else {
            return nil
        }
    }

    static var keyName: String {
        return String(describing: self)
    }
}

protocol SighInDelegate {
    func didUserSignIn(as user: GIDGoogleUser) -> Bool
    func didUserSignOut()
}

protocol UserProfile {
    var userName: String { get }
    var userInfo: String { get }
}

protocol Authenticatable {
    var authIdToken: String? { get }
    var authAccessToken: String? { get }
}

typealias SignInStorage = SighInDelegate & UserProfile & Authenticatable

class SignInModel: SignInStorage {
    private let userKey = GoogleUser.keyName
    private var _currentUser: GoogleUser?
    private var currentUser: GoogleUser? {
        if _currentUser == nil {
            _currentUser = LocalStorage.restoreObject(key: userKey)
            // OR we can use this:
            if let currentGoogleUser = GIDSignIn.sharedInstance.currentUser {
                _currentUser = GoogleUser(currentGoogleUser)
            }
        }
        return _currentUser
    }

    var userName: String {
        return currentUser?.fullName ?? "undefined"
    }

    var userInfo: String {
        return currentUser?.givenName ?? "info is not presented"
    }

    var authIdToken: String? {
        return currentUser?.idToken
    }

    var authAccessToken: String? {
        return currentUser?.accessToken
    }

    func didUserSignIn(as user: GIDGoogleUser) -> Bool {
        if let user = GoogleUser(user) {
            _currentUser = user
            return LocalStorage.saveObject(user, key: userKey)
        } else {
            print("Server Error: User data is wrong")
            return false
        }
    }

    func didUserSignOut() {
        _currentUser = nil
        LocalStorage.removeObject(key: userKey)
    }
}
