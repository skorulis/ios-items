//Created by Alexander Skorulis on 15/2/2026.

import Foundation

enum Artifact: Identifiable, Hashable, CaseIterable, Codable {
    
    case frictionlessGear
    
    var id: Self { self }
    
    var acronym: String {
        switch self {
        case .frictionlessGear:
            return "FG"
        }
    }
    
    var name: String {
        String(describing: self)
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
}

// MARK: - Bonus message

extension Artifact {
    func bonusMessage(quality: ItemQuality) -> String {
        switch self {
        case .frictionlessGear:
            return "Reduces item creation time by \(frictionlessGearTimeReduction(quality: quality)) milliseconds."
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
