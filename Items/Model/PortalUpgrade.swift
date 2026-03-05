//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import SwiftUI

/// A single line in an upgrade's cost: item type and required quantity.
struct UpgradeCostItem: Codable, Hashable {
    let item: BaseItem
    let quantity: Int
}

enum PortalUpgrade: Codable, Hashable, CaseIterable, Identifiable {
    case portalAutomation
    case researchLab
    case sacrifices
    case portalGlow

    var id: Self { self }

    var name: String {
        switch self {
        case .portalAutomation: return "Portal Automation"
        case .researchLab: return "Research Lab"
        case .sacrifices: return "Sacrifices"
        case .portalGlow: return "Portal Glow"
        }
    }

    var description: String? {
        switch self {
        case .portalAutomation: return "Automatically pulls items out of the portal."
        case .researchLab: return "Unlocks the Research lab."
        case .sacrifices: return "Unlocks the Sacrifices feature."
        case .portalGlow: return "Enhances the portal's visual aura."
        }
    }

    var image: Image? {
        switch self {
        case .portalAutomation: return Image(systemName: "play.circle.fill")
        case .researchLab: return Image(systemName: "flask.fill")
        case .sacrifices: return Image(systemName: "flame.fill")
        case .portalGlow: return Image(systemName: "circle.hexagongrid.fill")
        }
    }

    /// Items required to purchase this upgrade (item and quantity per line).
    var cost: [UpgradeCostItem] {
        switch self {
        case .portalAutomation: return [
            .init(item: .gear, quantity: 2),
            .init(item: .copperFlorin, quantity: 1)
        ]
        case .researchLab: return [
            .init(item: .potionFlask, quantity: 1),
            .init(item: .lens, quantity: 1),
            .init(item: .copperFlorin, quantity: 2),
        ]
        case .sacrifices: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .copperFlorin, quantity: 3),
        ]
        case .portalGlow: return [
            .init(item: .lens, quantity: 1),
            .init(item: .silverFlorin, quantity: 1),
            .init(item: .humanSkull, quantity: 1)
        ]
        }
    }
}
