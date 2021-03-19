//
//  LocalStorage.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation

struct LocalStorage {
    @discardableResult
    static func saveObject<T: Encodable>(_ object: T, key: String) -> Bool {
        var okOperation = false
        if let data = try? JSONEncoder().encode(object) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
            okOperation = true
        }
        return okOperation
    }

    static func restoreObject<T: Decodable>(key: String) -> T? {
        var savedObject: T?
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(T.self, from: data) {
                savedObject = object
            }
        }
        return savedObject
    }

    static func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
