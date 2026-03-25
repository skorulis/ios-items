// Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

public nonisolated enum Essence: String, Identifiable, Hashable, Codable, CaseIterable {
    case dark
    case light

    case chaos
    case order

    case earth
    case life

    case covenant
    case mind

    public var id: Self { self }
    public var name: String { String(describing: self).fromCaseName }
}

// MARK: - Descriptions

public extension Essence {
    /// A longer description of what the essence represents and how it fits into the world.
    var description: String {
        switch self {
        case .dark:
            return "Dark essence embodies shadow, mystery, and the unseen. Items touched by it often carry connotations of night, secrecy, or the hidden aspects of reality. Dark does not directly represent evil, but as functions as a counterpart when evil hides from view."
        case .earth:
            return "Earth essence is the stuff of stone, soil, and the enduring physical world. It defines the permanence of the natural order and the cycles of time."
        case .life:
            return "Life essence flows through growing things, healing arts, and all that thrives. It represents vitality, growth, and the bond between living beings. Death is also a part of life essence, as it is intertwined with the cycle of birth and rebirth. Life embodies change."
        case .light:
            return "Light essence carries clarity, warmth, and revelation. It illuminates truth and drives back confusion. "
        case .order:
            return "Order essence is the drive to take hold of the universe to impose law, predictability, and command to the randomness. It is not a specific craft or device but the abstract force of mastery and arrangement: making the cosmos answer. Technology is a manifestation of order, applying knowledge to control the world."
        case .chaos:
            return "Chaos essence embodies the parts of the universe that resist prediction, pattern, and explanation. It is not mere disorder but the deep limit of what can be known or controlled: potential without structure, change that cannot be fully mapped. Magic is based in chaos, where it can be harnessed without rational explanation."
        case .covenant:
            return "Covenant essence is the force of binding agreement: oaths, seals, trade, and currency that stands for a promise between people. It clings to minted coin, stamped wax, merchant marks, and anything whose power comes from mutual recognition rather than from the material alone."
        case .mind:
            return "Mind essence is the imprint of understanding: learning, memory, and the written or encoded word. Items that carry it—books, inscriptions, preserved lore—hold more than information; they hold the weight of what has been thought and passed down. To possess mind essence is to touch the continuity of minds across time."
        }
    }
}

public extension Essence {

    var color: Color {
        switch self {
        case .life: return .green
        case .covenant: return .orange
        case .chaos: return .purple
        case .order: return .indigo
        case .light: return .yellow
        case .dark: return .black
        case .earth: return .brown
        case .mind: return .cyan
        }
    }

    public var icon: Image {
        switch self {
        case .dark: return Image(systemName: "moon.fill")
        case .earth: return Image(systemName: "mountain.2.fill")
        case .life: return Image(systemName: "heart.fill")
        case .light: return Image(systemName: "sun.max.fill")
        case .chaos: return Image(systemName: "hurricane")
        case .order: return Image(systemName: "square.grid.3x3.fill")
        case .covenant: return Image(systemName: "checkmark.seal.fill")
        case .mind: return Image(systemName: "brain.head.profile")

        }
    }

    // Terms and concepts associated with this essence
    var associations: [String] {
        switch self {
        case .dark:
            return ["night", "shadow", "lies", "obscurity", "evil"]
        case .earth:
            return ["memory", "permanence", "land", "soil", "stone", "metal", "equilibrium"]
        case .life:
            return ["growth", "change", "energy"]
        case .light:
            return ["truth", "warmth", "beauty"]
        case .chaos:
            return ["magic", "confusion", "freedom"]
        case .order:
            return ["technology", "structure", "control"]
        case .covenant:
            return ["binding", "trade", "oaths"]
        case .mind:
            return ["knowledge", "lore", "symbols"]
        }
    }
}
