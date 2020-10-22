//
//  UserStorage.swift
//  YTLiveStreaming
//

import Foundation
import GoogleSignIn

internal let kUserDefaultsInstance = DataStorageImpl.default.instance
internal let kDataStorage = DataStorageImpl.default

class DataStorageImpl: NSObject {

    private override init() {
    }

    static let `default` = DataStorageImpl()
    static let sharingData = false

    enum DefaultKeyName {
        static let fullName = "com.ytlivevideo.fullName"
        static let token = "com.ytlivevideo.token"
    }

    var instance: UserDefaults {
        return UserDefaults.init()
    }

    private func isValueExist(_ key: String) -> Bool {
        return instance.object(forKey: key) != nil
    }

    private func removeValue(_ key: String) {
        guard self.isValueExist(key) else {
            return
        }
        instance.removeObject(forKey: key)
    }

    private func setString(_ key: String, _ value: String?) {
        if let value = value, !value.isEmpty {
            value.store(key: key)
        } else {
            removeValue(key)
        }
    }

    private func getString(_ key: String) -> String? {
        guard self.isValueExist(key) else {
            return nil
        }
        return String(key: key)
    }

    var fullName: String? {
        get {
            return getString(DefaultKeyName.fullName)
        }
        set {
            setString(DefaultKeyName.fullName, newValue)
        }
    }

    var token: String? {
        get {
            return getString(DefaultKeyName.token)
        }
        set {
            setString(DefaultKeyName.token, newValue)
        }
    }
}

extension String {

    init?(key: String) {
        guard let str = kUserDefaultsInstance.string(forKey: key) else { return nil }
        self.init(str)
    }

    func store(key: String) {
        kUserDefaultsInstance.set(self, forKey: key)
    }
}

// MARK: -

struct GoogleUser: Codable {
    let userId: String
    let idToken: String
    let fullName: String
    let givenName: String
    let familyName: String
    let email: String

    static func save(_ user: GIDGoogleUser) {
        if let userId = user.userID,                        // For client-side use only!
            let idToken = user.authentication.idToken {     // Safe to send to the server
            let fullName = user.profile.name ?? ""
            let givenName = user.profile.givenName ?? ""
            let familyName = user.profile.familyName ?? ""
            let email = user.profile.email ?? ""
            let googleUser = GoogleUser(userId: userId,
                                        idToken: idToken,
                                        fullName: fullName,
                                        givenName: givenName,
                                        familyName: familyName,
                                        email: email)
            UserStorage.user = googleUser
        } else {
            UserStorage.user = nil
            print("GIDGoogleUser is wrong")
        }
    }
}

struct UserStorage {

    static let kCurrentUserDataKey = "CurrentUserKey"

    static var user: GoogleUser? {
        get {
            let userDefaults = UserDefaults.standard
            if let data = userDefaults.data(forKey: UserStorage.kCurrentUserDataKey) {
                if let user = try? JSONDecoder().decode(GoogleUser.self, from: data) {
                    return user
                }
            }
            return nil
        }
        set {
            if let user = newValue {
                if let data = try? JSONEncoder().encode(user) {
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(data, forKey: UserStorage.kCurrentUserDataKey)
                    userDefaults.synchronize()
                }
            } else {
                let userDefaults = UserDefaults.standard
                userDefaults.removeObject(forKey: UserStorage.kCurrentUserDataKey)
            }
        }
    }
}
