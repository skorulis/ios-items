//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

// Research that has been done about an item
struct Research: Codable {
    let essences: [Essence]
    let artifact: Bool
    let lore: [String]
    
    public init(
        essences: Array<Essence> = [],
        artifact: Bool,
        lore: [String] = []
    ) {
        self.essences = essences
        self.artifact = artifact
        self.lore = lore
    }
    
    /// The level of research
    var level: Int {
        return sections.count
    }
    
    var sections: [ResearchSection] {
        var result = [ResearchSection]()
        for e in essences {
            result.append(.essence(e))
        }
        if artifact {
            result.append(.artifact)
        }
        for l in lore {
            result.append(.lore(l))
        }
        
        result.append(.infinity)
        return result
    }
    
    func isArtifactUnlocked(level: Int) -> Bool {
        guard artifact else { return false }
        
        // The level after unlocking essences is the artifact
        return level > essences.count
    }
    
    func unlockedEssences(level: Int) -> [Essence] {
        return Array(essences.prefix(level))
    }
}

enum ResearchSection: Identifiable {
    case essence(Essence)
    case artifact
    case lore(String)
    case infinity
    
    var id: String {
        switch self {
        case let .essence(essence):
            return String(describing: essence.id)
        case let .lore(string):
            return string
        case .artifact:
            return "artifact"
        case .infinity:
            return "infinity"
        }
    }
    
    var isInfinity: Bool {
        switch self {
        case .infinity:
            return true
        default:
            return false
        }
    }
    
    var iconColor: Color {
        switch self {
        case let .essence(essence):
            return essence.color
        default:
            return Color.white
        }
    }
    
}

struct ResearchProgress {
    let total: Research
    let current: Research
}
