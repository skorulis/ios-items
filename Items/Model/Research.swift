// Created by Alexander Skorulis on 13/2/2026.

import Foundation
import Models
import SwiftUI

// Research that has been done about an item
struct Research: Codable {
    let essences: [Essence]
    let lore: [String]

    public init(
        essences: [Essence] = [],
        lore: [String] = []
    ) {
        self.essences = essences
        self.lore = lore
    }

    /// The level of research
    var level: Int {
        return sections.count
    }

    var sections: [ResearchSection] {
        var result = [ResearchSection]()
        for ess in essences {
            result.append(.essence(ess))
        }
        for lore in self.lore {
            result.append(.lore(lore))
        }

        result.append(.infinity)
        return result
    }

    func unlockedEssences(level: Int) -> [Essence] {
        return Array(essences.prefix(level))
    }
}

enum ResearchSection: Identifiable {
    case essence(Essence)
    case lore(String)
    case infinity

    var id: String {
        switch self {
        case let .essence(essence):
            return String(describing: essence.id)
        case let .lore(string):
            return string
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
