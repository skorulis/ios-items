//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
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
    case artifactSlot
    case artifactSlotLevel2
    case artifactSlotLevel3
    case knowledgeSiphon
    case knowledgeSiphonLevel2
    case knowledgeSiphonLevel3
    case knowledgeSiphonLevel4
    case knowledgeSiphonLevel5

    var id: Self { self }

    var name: String {
        switch self {
        case .portalAutomation: return "Portal Automation"
        case .researchLab: return "Research Lab"
        case .researchLabLevel2: return "Research Lab II"
        case .sacrifices: return "Sacrifices"
        case .artifactSlot: return "Artifact Slot"
        case .artifactSlotLevel2: return "Artifact Slot II"
        case .artifactSlotLevel3: return "Artifact Slot III"
        case .knowledgeSiphon: return "Knowledge Siphon"
        case .knowledgeSiphonLevel2: return "Knowledge Siphon II"
        case .knowledgeSiphonLevel3: return "Knowledge Siphon III"
        case .knowledgeSiphonLevel4: return "Knowledge Siphon IV"
        case .knowledgeSiphonLevel5: return "Knowledge Siphon V"
        }
    }

    var description: String? {
        switch self {
        case .portalAutomation: return "Automatically pulls items out of the portal."
        case .researchLab: return "Unlocks the Research lab."
        case .sacrifices: return "Unlocks the Sacrifices feature."
        case .artifactSlot: return "Unlocks one equipped artifact slot."
        case .artifactSlotLevel2: return "Unlocks a second equipped artifact slot."
        case .artifactSlotLevel3: return "Unlocks a third equipped artifact slot."
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
        case .artifactSlot, .artifactSlotLevel2, .artifactSlotLevel3: return Image(systemName: "square.stack.3d.up.fill")
        case .knowledgeSiphon, .knowledgeSiphonLevel2, .knowledgeSiphonLevel3, .knowledgeSiphonLevel4, .knowledgeSiphonLevel5: return Image(systemName: "book.fill")
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
        case .artifactSlot: return [
            .init(item: .lens, quantity: 1),
            .init(item: .copperFlorin, quantity: 2),
        ]
        case .artifactSlotLevel2: return [
            .init(item: .lens, quantity: 2),
            .init(item: .silverFlorin, quantity: 1),
        ]
        case .artifactSlotLevel3: return [
            .init(item: .lens, quantity: 3),
            .init(item: .goldFlorin, quantity: 1),
        ]
        case .knowledgeSiphon: return [
            .init(item: .book, quantity: 2),
            .init(item: .lens, quantity: 1),
            .init(item: .silverFlorin, quantity: 1),
        ]
        case .knowledgeSiphonLevel2: return [
            .init(item: .book, quantity: 4),
            .init(item: .lens, quantity: 2),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .knowledgeSiphonLevel3: return [
            .init(item: .book, quantity: 6),
            .init(item: .lens, quantity: 3),
            .init(item: .goldFlorin, quantity: 1),
        ]
        case .knowledgeSiphonLevel4: return [
            .init(item: .book, quantity: 10),
            .init(item: .lens, quantity: 4),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .knowledgeSiphonLevel5: return [
            .init(item: .book, quantity: 14),
            .init(item: .lens, quantity: 5),
            .init(item: .goldFlorin, quantity: 3),
        ]
        }
    }

    /// Requirements that must all be met before this upgrade becomes available.
    var requirements: [UnlockRequirement] {
        switch self {
        case .researchLabLevel2:
            return [.upgradePurchased(.researchLab)]
        case .artifactSlotLevel2:
            return [
                .upgradePurchased(.artifactSlot),
                .achievementUnlocked(.artifacts5),
            ]
        case .artifactSlotLevel3:
            return [.upgradePurchased(.artifactSlotLevel2)]
        case .knowledgeSiphon:
            return [.upgradePurchased(.researchLab)]
        case .knowledgeSiphonLevel2:
            return [.upgradePurchased(.knowledgeSiphon)]
        case .knowledgeSiphonLevel3:
            return [.upgradePurchased(.knowledgeSiphonLevel2)]
        case .knowledgeSiphonLevel4:
            return [.upgradePurchased(.knowledgeSiphonLevel3)]
        case .knowledgeSiphonLevel5:
            return [.upgradePurchased(.knowledgeSiphonLevel4)]
        default:
            return []
        }
    }

    /// Optional gameplay bonus granted by this upgrade.
    var bonus: Bonus? {
        switch self {
        case .researchLabLevel2:
            return .researchSpeed(10)
        case .artifactSlot, .artifactSlotLevel2, .artifactSlotLevel3:
            return .artifactSlots(1)
        case .knowledgeSiphon:
            return .booksForResearch(.junk)
        case .knowledgeSiphonLevel2:
            return .booksForResearch(.common)
        case .knowledgeSiphonLevel3:
            return .booksForResearch(.good)
        case .knowledgeSiphonLevel4:
            return .booksForResearch(.rare)
        case .knowledgeSiphonLevel5:
            return .booksForResearch(.exceptional)
        default:
            return nil
        }
    }

}
