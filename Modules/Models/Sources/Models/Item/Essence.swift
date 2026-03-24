// Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

public nonisolated enum Essence: String, Identifiable, Hashable, Codable, CaseIterable {
    case dark
    case light
    case earth
    case life
    case chaos
    case order
    
    // LEGACY
    case magic
    case technology
    case wealth
    case knowledge

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
            
            
        case .magic:
            return "Magic essence is raw potential—the spark that bends rules and makes the impossible plausible. It infuses items with arcane affinity, enabling rituals, enchantments, and phenomena beyond ordinary cause and effect. Those who seek it walk the line between wonder and risk."
        case .technology:
            return "Technology essence represents ingenuity, mechanism, and the application of knowledge to matter. It lives in crafted devices, precise instruments, and the tools that extend human capability. In this world, technology is not opposed to magic but another channel through which order is imposed on chaos."
        case .wealth:
            return "Wealth essence captures the idea of value, exchange, and abundance. It clings to currency, trade goods, and objects that have gathered meaning through commerce or hoarding. It does not merely mean gold—it is the abstract force of worth that societies build upon."
        case .knowledge:
            return "Knowledge essence is the imprint of understanding: learning, memory, and the written or encoded word. Items that carry it—books, inscriptions, preserved lore—hold more than information; they hold the weight of what has been thought and passed down. To possess knowledge essence is to touch the continuity of minds across time."
        }
    }
}

public extension Essence {
    
    // The essence that represents the opposite
    var opposite: Essence {
        switch self {
        case .dark: return .light
        case .earth: return .life
        case .life: return .earth
        case .light: return .dark
        case .chaos: return .order
        case .order: return .chaos
            
        // LEGACY
        case .magic: fatalError()
        case .technology: fatalError()
        case .wealth: fatalError()
        case .knowledge: fatalError()
        }
    }
    
    var color: Color {
        switch self {
        case .life: return .green
        case .wealth: return .orange
        case .chaos: return .purple
        case .order: return .indigo
        case .magic: return .blue
        case .technology: return .gray
        case .light: return .yellow
        case .dark: return .black
        case .earth: return .brown
        case .knowledge: return .cyan
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
        case .magic: return Image(systemName: "sparkles")
        case .technology: return Image(systemName: "cpu")
        case .wealth: return Image(systemName: "banknote.fill")
        case .knowledge: return Image(systemName: "book.fill")
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
            return ["magic", "confusion"]
        case .order:
            return ["technology", "structure", "law"]
            
            // LEGACY
        case .magic, .technology, .wealth, .knowledge:
            return []
        }
    }
}
