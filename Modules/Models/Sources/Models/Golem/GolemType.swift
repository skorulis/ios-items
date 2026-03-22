// Created by Alexander Skorulis on 23/3/2026.

import Foundation

/// Constructible golem variants; each can be purchased repeatedly for item costs.
public enum GolemType: String, Codable, Hashable, CaseIterable, Identifiable {
    case clay
    case iron
    case crystal

    public var id: Self { self }

    public var name: String {
        switch self {
        case .clay: return "Clay Golem"
        case .iron: return "Iron Golem"
        case .crystal: return "Crystal Golem"
        }
    }

    public var description: String {
        switch self {
        case .clay:
            return "A simple animated figure. Inexpensive to build in bulk."
        case .iron:
            return "Sturdier frame and better focus. Costs more refined materials."
        case .crystal:
            return "Channels ambient energy. The most demanding build."
        }
    }

    /// Longer help text for the info overlay.
    public var detailedExplanation: String {
        switch self {
        case .clay:
            return "Clay golems are your basic constructs. They are cheap to assemble and a good way to grow your workforce early."
        case .iron:
            return "Iron golems trade higher material cost for a more reliable body. Use them when you need constructs that last."
        case .crystal:
            return "Crystal golems bind light and resonance into the shell. They are expensive but represent your top tier of manual constructs."
        }
    }

    public var cost: [UpgradeCostItem] {
        switch self {
        case .clay:
            return [
                .init(item: .rock, quantity: 5),
                .init(item: .gear, quantity: 1),
                .init(item: .copperFlorin, quantity: 2),
            ]
        case .iron:
            return [
                .init(item: .gear, quantity: 3),
                .init(item: .metalBloom, quantity: 2),
                .init(item: .silverFlorin, quantity: 2),
            ]
        case .crystal:
            return [
                .init(item: .quartzCrystal, quantity: 2),
                .init(item: .lens, quantity: 2),
                .init(item: .goldFlorin, quantity: 1),
            ]
        }
    }
}
