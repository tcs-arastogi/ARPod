//
//  TimeInterval+Extensions.swift
//  ARDesignerApp
//
//  Created by Mykhailo Lysenko on 5/31/22.
//

import Foundation

extension TimeInterval {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM, yyyy, h:mm a"
        formatter.timeZone = TimeZone(abbreviation: "en_US_POSIX")
        
        return formatter
    }()
    
    func toDateString() -> String {
        Self.dateFormatter.string(from: Date(timeIntervalSince1970: self))
    }
}
