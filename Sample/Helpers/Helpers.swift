//  Helpers.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation

class Helpers {
    /**
        Computes date after appropriated hours, minutes, seconds
     */
    static func dateAfter(_ date: Date,
                          hour: Int = 0,
                          minute: Int = 0,
                          second: Int = 0) -> Date {
        let calendar = Calendar.current
        if let date = (calendar as NSCalendar).date(byAdding: .hour, value: hour, to: date, options: []) {
            if let date = (calendar as NSCalendar).date(byAdding: .minute, value: minute, to: date, options: []) {
                if let date = (calendar as NSCalendar).date(byAdding: .second, value: second, to: date, options: []) {
                    return date
                }
            }
        }
        return date
    }
}
