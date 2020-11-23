//
//  Extensions.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import Foundation

extension Date {
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
    
    var year: Int { calendar.component(.year, from: self) }
    var month: Int { calendar.component(.month, from: self) }
    var day: Int { calendar.component(.day, from: self) }
    var hour: Int { calendar.component(.hour, from: self) }
    var minute: Int { calendar.component(.minute, from: self) }
    var second: Int { calendar.component(.second, from: self) }
    
    func time(as format: String = "HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}
