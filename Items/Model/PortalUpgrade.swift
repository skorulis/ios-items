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
    case researchLabLevel2
    case sacrifices

    var id: Self { self }

    var name: String {
        switch self {
        case .portalAutomation: return "Portal Automation"
        case .researchLab: return "Research Lab"
        case .researchLabLevel2: return "Research Lab II"
        case .sacrifices: return "Sacrifices"
        }
    }

    var description: String? {
        switch self {
        case .portalAutomation: return "Automatically pulls items out of the portal."
        case .researchLab: return "Unlocks the Research lab."
        case .sacrifices: return "Unlocks the Sacrifices feature."
        default:
            return self.bonus?.text ?? "TODO: Set manual description or add bonus"
        }
    }

    var image: Image? {
        switch self {
        case .portalAutomation: return Image(systemName: "play.circle.fill")
        case .researchLab: return Image(systemName: "flask.fill")
        case .researchLabLevel2: return Image(systemName: "flask.fill")
        case .sacrifices: return Image(systemName: "flame.fill")
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
        case .researchLabLevel2: return [
            .init(item: .potionFlask, quantity: 2),
            .init(item: .lens, quantity: 2),
            .init(item: .silverFlorin, quantity: 1),
        ]
        case .sacrifices: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .copperFlorin, quantity: 3),
        ]
        }
    }

    /// Optional requirement that must be met before this upgrade becomes available.
    var requirement: UnlockRequirement? {
        switch self {
        case .researchLabLevel2:
            return .upgradePurchased(.researchLab)
        default:
            return nil
        }
    }

    /// Optional gameplay bonus granted by this upgrade.
    var bonus: Bonus? {
        switch self {
        case .researchLabLevel2:
            return .researchSpeed(10)
        default:
            return nil
        }
    }

}
