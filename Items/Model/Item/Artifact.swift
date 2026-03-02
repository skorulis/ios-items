//Created by Alexander Skorulis on 15/2/2026.

import Foundation

enum Artifact: Identifiable, Hashable, CaseIterable, Codable {
    
    case frictionlessGear
    case eternalHourglass
    case luckyCoin
    
    var id: Self { self }
    
    var name: String {
        String(describing: self).fromCaseName
    }
    
    
}

// MARK: - Bonuses

extension Artifact {
    
    func frictionlessGearTimeReduction(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 100
        case .common: return 200
        case .good: return 300
        case .rare: return 400
        case .exceptional: return 500
        }
    }
    
    func eternalHourglassTimeReduction(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 500
        case .common: return 1000
        case .good: return 1500
        case .rare: return 2000
        case .exceptional: return 2500
        }
    }
    
    func luckyCoinMultipleItemChance(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 10
        case .common: return 20
        case .good: return 30
        case .rare: return 40
        case .exceptional: return 50
        }
    }
}

// MARK: - Bonus message

extension Artifact {
    func bonusMessage(quality: ItemQuality) -> String {
        switch self {
        case .frictionlessGear:
            return "Reduces item creation time by \(frictionlessGearTimeReduction(quality: quality)) milliseconds."
        case .eternalHourglass:
            return "Reduces automatic item creation time by \(eternalHourglassTimeReduction(quality: quality)) milliseconds"
        case .luckyCoin:
            return "Increase the chance of double items by \(luckyCoinMultipleItemChance(quality: quality)) percent"
        }
    }
}

// MARK: -

struct ArtifactInstance {
    let type: Artifact
    let quality: ItemQuality
    
    var bonusMessage: String {
        type.bonusMessage(quality: quality)
    }
    
}
