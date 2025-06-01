//
//  DateX.swift
//  EasyAC
//
//  Created by 55 agency on 27/12/23.
//

import UIKit

extension Date {
    
    func toLocalString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        // Set the date format
        dateFormatter.dateFormat = format
        // Use the device's local time zone
        dateFormatter.timeZone = TimeZone.current
        // Format the date to string
        return dateFormatter.string(from: self)
    }
    
    func toUTCString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        // Set the date format
        dateFormatter.dateFormat = format
        // UTC time zone
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        // Format the date to string
        return dateFormatter.string(from: self)
    }
    
    static func fromUTCTimestampInMillis(_ timestamp: Int64) -> Date {
        // Convert milliseconds to seconds by dividing by 1000
        return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
    
    func toDateString(dateFormateString: String) -> String {
        return Global.GetFormattedDate(date: self, outputFormate: dateFormateString, isInputUTC: true, isOutputUTC: false).dateString ?? ""
    }
    
    func toFormattedDate(dateFormateString: String) -> String {
        let createdDate = Global.GetFormattedDate(date: self, outputFormate: "dd MMM yyyy HH:mm:ss", isInputUTC: false, isOutputUTC: false).date ?? Date()
        let currentDate = Global.GetFormattedDate(date: Date(), outputFormate: "dd MMM yyyy HH:mm:ss", isInputUTC: false, isOutputUTC: false).date ?? Date()
        
        let yesterday = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: currentDate)
        let compareWithToday = Calendar(identifier: .gregorian).compare(currentDate, to: createdDate, toGranularity: Calendar.Component.day)
        let compareWithYesterday = Calendar(identifier: .gregorian).compare(yesterday!, to: createdDate, toGranularity: Calendar.Component.day)
        if compareWithToday == ComparisonResult.orderedSame || Calendar.current.isDateInToday(createdDate) {
            return "Aujourd'hui".localized
        } else if compareWithYesterday == ComparisonResult.orderedSame || Calendar.current.isDateInYesterday(createdDate) {
            return "Hier".localized
        } else {
            return Global.GetFormattedDate(date: self, outputFormate: dateFormateString, isInputUTC: true, isOutputUTC: false).dateString ?? ""
        }
    }
    
    func toMillis() -> Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
}
