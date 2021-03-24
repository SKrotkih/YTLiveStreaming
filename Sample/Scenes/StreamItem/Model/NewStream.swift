//
//  NewStream.swift
//  LiveEvents
//
//  Created by Сергей Кротких on 24.03.2021.
//  Copyright © 2021 Sergey Krotkih. All rights reserved.
//

import Foundation

struct NewStream {
    var title: String
    var description: String
    var hours: String
    var minutes: String
    var seconds: String
    var date: Date

    func verification() -> Bool {
        return !title.isEmpty && startStreaming > Date()
    }

    var startStreaming: Date {
        let h = hours.isEmpty ? 0 : Int(hours) ?? 0
        let m = minutes.isEmpty ? 0 : Int(minutes) ?? 0
        let s = seconds.isEmpty ? 0 : Int(seconds) ?? 0
        if h + m + s > 0 {
            return Date().add(hours: h > 24 ? 0 : h, minutes: m > 60 ? 0 : m, seconds: s > 60 ? 0 : s)
        } else {
            return date
        }
    }
}
