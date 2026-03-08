//Created by Alexander Skorulis on 5/3/2026.

import Foundation

enum Bonus {
    case researchSpeed(Int)
    case artifactSlots(Int)
    case qualityBoost(Int, ItemQuality)
    
    var text: String {
        switch self {
        case let .researchSpeed(int):
            return "Boost research speed by \(int)%"
        case let .artifactSlots(int):
            return "Add \(int) artifact slot"
        case let .qualityBoost(amount, quality):
            return "Boost the chance to find \(quality.name) items by \(amount) percent"
        }
    }
    
    var researchSpeedBoost: Int {
        switch self {
        case let .researchSpeed(int):
            return int
        default:
            return 0
        }
    }
    
    var artifactSlotBoost: Int {
        switch self {
        case .artifactSlots(let int):
            return int
        default:
            return 0
        }
    }
}

extension Array where Element == Bonus {
    var researchSpeed: Int {
        return self.map { $0.researchSpeedBoost }.reduce(0, +)
    }
    
    var artifactSlots: Int {
        return self.map { $0.artifactSlotBoost }.reduce(0, +)
    }
}
