// Created by Alexander Skorulis on 2/3/2026.
//
// Represents a probability as a fraction between 0 and 1.

import Foundation

struct Chance: Codable, Hashable {
    
    let value: Double
    
    /// Creates a chance from a fractional value between 0 and 1.
    /// Values outside this range are clamped.
    init(_ fraction: Double) {
        self.value = max(0, min(1, fraction))
    }
    
    /// The underlying fractional value, guaranteed to be between 0 and 1.
    var fraction: Double { value }
    
    /// Returns the chance formatted as a percentage string, e.g. "12.5%".
    func percentageString(decimalPlaces: Int = 1) -> String {
        let format = "%.\(decimalPlaces)f%%"
        return String(format: format, fraction * 100)
    }
    
    func check() -> Bool {
        let roll = Double.random(in: 0...1)
        return roll <= fraction
    }
}

