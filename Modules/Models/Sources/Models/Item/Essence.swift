// Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

public nonisolated enum Essence: String, Identifiable, Hashable, Codable, CaseIterable {
    case dark
    case earth
    case life
    case light
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
            return "Dark essence embodies shadow, mystery, and the unseen. Items touched by it often carry connotations of night, secrecy, or the hidden aspects of reality. In the world's balance, dark stands opposite to light—not as evil, but as the necessary counterpart that gives depth and rest to creation."
        case .earth:
            return "Earth essence is the stuff of stone, soil, and the enduring physical world. It grounds items in permanence and substance, and is often found in minerals, tools, and anything that has weathered time. Those who work with earth understand stability, craft, and the slow patience of the land."
        case .life:
            return "Life essence flows through growing things, healing arts, and all that thrives. It represents vitality, growth, and the bond between living beings. Items rich in life essence are prized for restoration and renewal, and are deeply tied to nature and the cycle of birth and decay."
        case .light:
            return "Light essence carries clarity, warmth, and revelation. It illuminates truth and drives back confusion; items imbued with it often serve guidance, protection, or the uncovering of what was hidden. In the world's cosmology, light is the active principle of day and awareness."
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
    var color: Color {
        switch self {
        case .life: return .green
        case .wealth: return .orange
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
        case .magic: return Image(systemName: "sparkles")
        case .technology: return Image(systemName: "cpu")
        case .wealth: return Image(systemName: "banknote.fill")
        case .knowledge: return Image(systemName: "book.fill")
        }
    }
}
