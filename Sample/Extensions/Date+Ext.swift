//  Helpers.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import Foundation

extension Date {
    /**
     Computes date after appropriated hours, minutes, seconds
     */
    func add(
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0) -> Date {
        let calendar = Calendar.current
        if let date = (calendar as NSCalendar).date(byAdding: .hour, value: hours, to: self, options: []) {
            if let date = (calendar as NSCalendar).date(byAdding: .minute, value: minutes, to: date, options: []) {
                if let date = (calendar as NSCalendar).date(byAdding: .second, value: seconds, to: date, options: []) {
                    return date
                }
            }
        }
        return self
    }
}
