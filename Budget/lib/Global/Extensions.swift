//
//  Extensions.swift
//  Budget
//
//  Created by Elisey Ozerov on 16/11/2020.
//  Copyright © 2020 Elisey Ozerov. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Date {
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale.current
        return calendar
    }
    
    init(from components: DateComponents) {
        self = Calendar.current.date(from: components)!
    }
    
    var year: Int { calendar.component(.year, from: self) }
    var month: Int { calendar.component(.month, from: self) }
    var day: Int { calendar.component(.day, from: self) }
    var weekday: Int {
        var index = calendar.component(.weekday, from: self) - calendar.firstWeekday
        if index < 0 {
            index = index + 7
        }
        return index
    }
    var hour: Int { calendar.component(.hour, from: self) }
    var minute: Int { calendar.component(.minute, from: self) }
    var second: Int { calendar.component(.second, from: self) }
    
    static var weekdaySymbols: [String] { DateFormatter().weekdaySymbols }
    
    func time(as format: String = "HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func before(_ other: Date) -> Bool {
        return self < other
    }
    
    func after(_ other: Date) -> Bool {
        return self > other
    }
    
    func between(start: Date, end: Date) -> Bool {
        return self.after(start) && self.before(end)
    }
    
    func equal(_ other: Date) -> Bool {
        return self == other
    }
    
    func add(component: Calendar.Component, value: Int) -> Date {
        return calendar.date(byAdding: component, value: value, to: self)!
    }
    
    func subtract(component: Calendar.Component, value: Int) -> Date {
        return calendar.date(byAdding: component, value: -value, to: self)!
    }
    
    func format(format: String? = "dd MMMM yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func startOfDay() -> Date {
        return calendar.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        return calendar.date(byAdding: .day, value: 1, to: startOfDay())!
    }
}

extension String {
    func toDouble() -> Double {
        // define regex to remove non-numeric characters
        let regex = try! NSRegularExpression(pattern: "[^0-9]")
        // get string representation of all numeric characters
        let string = regex.stringByReplacingMatches(in: self, range: NSMakeRange(0, self.count), withTemplate: "")
        // assuming 2 decimal places for formatted string value
        return (string as NSString).doubleValue / 100
    }
}

extension Double {
    func toCurrencyString() -> String {
        // define the formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .init(identifier: "si_SI")
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        // format the double
        let number = NSNumber(value: self)
        let res = formatter.string(from: number)!
        return res
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}

struct Height: View {
    var height: CGFloat
    
    init(_ height: CGFloat) {
        self.height = height
    }
    
    var body: some View {
        Spacer()
            .frame(width: 0, height: height)
    }
}
