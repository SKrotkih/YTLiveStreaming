//
//  Helpers.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 11/12/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import Foundation

class Helpers {

   class func dateAfter(_ date: Date, after: (hour: NSInteger, minute: NSInteger, second: NSInteger)) -> Date {
      let calendar = Calendar.current
      if let date = (calendar as NSCalendar).date(byAdding: .hour, value: after.hour, to: date, options: []) {
         if let date = (calendar as NSCalendar).date(byAdding: .minute, value: after.minute, to: date, options: []) {
            if let date = (calendar as NSCalendar).date(byAdding: .second, value: after.second, to: date, options: []) {
               return date
            }
         }
      }
      return date
   }
   
}




