//Created by Alexander Skorulis on 5/3/2026.

import Foundation

enum Bonus {
    case researchSpeed(Int)
    
    var text: String {
        switch self {
        case let .researchSpeed(int):
            return "Boost research speed by \(int)%"
        }
    }
    
    var researchSpeedBoost: Int {
        switch self {
        case let .researchSpeed(int):
            return int
        }
    }
}

extension Array where Element == Bonus {
    var researchSpeed: Int {
        return self.map { $0.researchSpeedBoost }.reduce(0, +)
    }
}
