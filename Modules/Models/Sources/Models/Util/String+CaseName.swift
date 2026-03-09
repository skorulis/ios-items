// Created by Alexander Skorulis on 19/2/2026.

import Foundation

public extension String {
    /// Converts a camelCase name like "eternalHourglass" into a human string "Eternal Hourglass"
    var fromCaseName: String {
        let spaced = self
            .replacingOccurrences(of: "([a-z0-9])([A-Z])", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "_", with: " ")

        let words = spaced.split(whereSeparator: { $0.isWhitespace })
            .map { word -> String in
                let lower = word.lowercased()
                return lower.prefix(1).uppercased() + lower.dropFirst()
            }

        return words.joined(separator: " ")
    }
}
