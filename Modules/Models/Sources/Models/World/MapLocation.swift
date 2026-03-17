// Created by Cursor on 16/3/2026.

import Foundation

/// A location that can be unlocked on the world map.
public enum MapLocation: String, CaseIterable, Identifiable, Hashable, Codable {
    case vesprium
    case semilTradingPost

    public var id: Self { self }

    public var name: String {
        String(describing: self).fromCaseName
    }

    /// Convenience passthrough to `details.description`.
    public var description: String {
        details.description
    }

    /// All configurable parameters for a map location.
    public var details: LocationDetails {
        switch self {
        case .vesprium:
            return LocationDetails(
                description: "Vesprium is the name of the world in the dimension you have discovered.",
                essenceMultipliers: [:],
                uniqueItems: [],
                cost: [] // Unlocked by default
            )
        case .semilTradingPost:
            return LocationDetails(
                description: "A quaint trading post with a bustling marketplace surrounding a fountain of shimmering water.",
                essenceMultipliers: [
                    .wealth: 1.5,
                    .knowledge: 1.1,
                    .dark: 0,
                    .earth: 0
                ],
                uniqueItems: [.merchantSigil],
                cost: [
                    UpgradeCostItem(item: .mapFragment, quantity: 1),
                    UpgradeCostItem(item: .silverFlorin, quantity: 1)
                ]
            )
        }
    }
}

public struct LocationDetails: Codable, Hashable {
    public let description: String
    public let essenceMultipliers: [Essence: Double]
    public let uniqueItems: [BaseItem]
    /// Cost to unlock or travel to this location (item and quantity per line).
    public let cost: [UpgradeCostItem]

    public init(
        description: String,
        essenceMultipliers: [Essence: Double],
        uniqueItems: [BaseItem] = [],
        cost: [UpgradeCostItem] = []
    ) {
        self.description = description
        self.essenceMultipliers = essenceMultipliers
        self.uniqueItems = uniqueItems
        self.cost = cost
    }

    public func multiplier(for essence: Essence) -> Double {
        essenceMultipliers[essence] ?? 1.0
    }
}
