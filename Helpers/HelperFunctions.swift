//
//  HelperFunctions.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI



final class Helper {
    
    static let shared = Helper()
    
    private init() { }
    
    
    // combine 'prettyDate' (date) and 'daysFromToday' (counter)
    func sectionHeaderInfo(for date: Date) -> String {
        let prettyDate      = prettyDate(date)
        let daysFromToday   = daysFromToday(date)
        return String("\(prettyDate) \(daysFromToday)")
    }
    

    // simplify date e.g. "11 January"
    func prettyDate(_ date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    

    // calculate elapsed days
    func daysFromToday(_ date: Date) -> String {
        let calendar        = Calendar.current
        let startOfToday    = calendar.startOfDay(for: .now)
        let startOfDate     = calendar.startOfDay(for: date)

        let days = calendar.dateComponents([.day], from: startOfDate, to: startOfToday).day ?? 0
        return "[+\(abs(days)) day\(abs(days) == 1 ? "" : "s")]"
    }
    

    // filter digits to one decimal and two fractional (e.g. "1.23")
    func filterNumericInput(_ input: String) -> String {
        // remove any character not in "0123456789."
        let filtered = input.filter { "0123456789.".contains($0) }
        
        // split string into components around the "." char
        let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)

        switch parts.count {
        case 0  : return ""                                     // empty string or contains no numeric chars
        case 1  : return String(parts[0])                       // absent decimal point (".")
        default : return parts[0] + "." + parts[1].prefix(2)    // keep first number before the period and two digits after (e.g. "1.23")
        }
    }
}
