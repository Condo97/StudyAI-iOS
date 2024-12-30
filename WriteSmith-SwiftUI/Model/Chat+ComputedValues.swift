//
//  Chat+ComputedValues.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 4/29/24.
//

import Foundation

extension Chat {
    
    @objc public var daySectionIdentifier: String {
        guard let chatDate = date else { return "Unknown" }
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        // Check if the date is 'Today'
        if calendar.isDateInToday(chatDate) {
            return "Today"
        }
        
        // Check if the date is 'Yesterday'
        if calendar.isDateInYesterday(chatDate) {
            return "Yesterday"
        }
        
        // Determine if the date is from the current year or previous year
        let currentYear = calendar.component(.year, from: Date())
        let chatDateYear = calendar.component(.year, from: chatDate)
        
        if chatDateYear == currentYear {
            dateFormatter.dateFormat = "MMM dd"
        } else {
            dateFormatter.dateFormat = "MMM dd, yyyy"
        }
        
        return dateFormatter.string(from: chatDate)
    }
    
}
