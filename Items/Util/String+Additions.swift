//Created by Alexander Skorulis on 19/2/2026.

import Foundation

nonisolated extension String {
    
    func acronym(_ maxLength: Int = 2) -> String {
        let value =  split(separator: " ")
            .map { $0.prefix(1) }
            .joined()
            .uppercased()
            .prefix(maxLength)
        
        return String(value)
    }
    
    // Converts a snake case name like "eternalHourglass" into a human string "Eternal Hourglass"
    var fromCaseName: String {
        // Handle snake_case by replacing underscores with spaces first
        let spaced = self
            // Insert a space before each uppercase letter that follows a lowercase or number (camelCase/PascalCase)
            .replacingOccurrences(of: "([a-z0-9])([A-Z])", with: "$1 $2", options: .regularExpression)
            // Replace underscores with spaces (snake_case)
            .replacingOccurrences(of: "_", with: " ")
        
        // Split on whitespace, lowercase each word, then capitalize first letter
        let words = spaced.split(whereSeparator: { $0.isWhitespace })
            .map { word -> String in
                let lower = word.lowercased()
                return lower.prefix(1).uppercased() + lower.dropFirst()
            }
        
        return words.joined(separator: " ")
    }
}

