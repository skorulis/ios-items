//Created by Alexander Skorulis on 15/2/2026.

import Foundation

enum Artifact: Identifiable, Hashable, CaseIterable, Codable {
    
    case frictionlessGear
    case eternalHourglass
    
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
}

// MARK: - Bonus message

extension Artifact {
    func bonusMessage(quality: ItemQuality) -> String {
        switch self {
        case .frictionlessGear:
            return "Reduces item creation time by \(frictionlessGearTimeReduction(quality: quality)) milliseconds."
        case .eternalHourglass:
            return "Reduces automatic item creation time by \(eternalHourglassTimeReduction(quality: quality)) milliseconds"
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
