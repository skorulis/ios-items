// Created by Alexander Skorulis on 5/3/2026.
//
// Core model for portal upgrades shared across the app.

import Foundation

public enum PortalUpgrade: String, Codable, Hashable, CaseIterable, Identifiable {
    /// Root of the upgrade tree; all other upgrades require this (directly or via ancestors).
    case portalUnlocked
    case portalAutomation
    case portalAutomationLevel2
    case portalAutomationLevel3
    case portalAutomationLevel4
    case portalAutomationLevel5
    case portalDuplication
    case portalDuplicationLevel2
    case portalDuplicationLevel3
    case portalDuplicationLevel4
    case portalDuplicationLevel5
    case researchLab
    case researchLabLevel2
    case researchLabLevel3
    case researchLabLevel4
    case researchLabLevel5
    case sacrifices
    case sacrificesLevel2
    case sacrificesLevel3
    case sacrificesLevel4
    case sacrificesLevel5
    case sacrificesPower
    case sacrificesPowerLevel2
    case sacrificesPowerLevel3
    case sacrificesPowerLevel4
    case sacrificesPowerLevel5
    case artifactSlot
    case artifactSlotLevel2
    case artifactSlotLevel3
    case knowledgeSiphon
    case knowledgeSiphonLevel2
    case knowledgeSiphonLevel3
    case knowledgeSiphonLevel4
    case knowledgeSiphonLevel5
    case offlineProgress
    case offlineProgressLevel2
    case offlineProgressLevel3
    case offlineProgressLevel4
    case offlineProgressLevel5
    case mapLocations
    case tradingPost
    case tradingPostLevel2
    case tradingPostLevel3
    case golems
    case golemMissionSlotsLevel2
    case golemMissionSlotsLevel3
    case golemMissionSlotsLevel4
    case golemMissionSlotsLevel5
    /// Unlocks the Warehouse equipment tab and the chance to discover equipment recipes from sacrifices.
    case crafting

    public var id: Self { self }

    public var name: String {
        switch self {
        case .portalUnlocked: return "Portal Unlocked"
        case .portalAutomation: return "Portal Automation"
        case .portalAutomationLevel2: return "Portal Automation II"
        case .portalAutomationLevel3: return "Portal Automation III"
        case .portalAutomationLevel4: return "Portal Automation IV"
        case .portalAutomationLevel5: return "Portal Automation V"
        case .portalDuplication: return "Portal Duplication"
        case .portalDuplicationLevel2: return "Portal Duplication II"
        case .portalDuplicationLevel3: return "Portal Duplication III"
        case .portalDuplicationLevel4: return "Portal Duplication IV"
        case .portalDuplicationLevel5: return "Portal Duplication V"
        case .researchLab: return "Research Lab"
        case .researchLabLevel2: return "Research Lab II"
        case .researchLabLevel3: return "Research Lab III"
        case .researchLabLevel4: return "Research Lab IV"
        case .researchLabLevel5: return "Research Lab V"
        case .sacrifices: return "Sacrifices"
        case .sacrificesLevel2: return "Sacrifices II"
        case .sacrificesLevel3: return "Sacrifices III"
        case .sacrificesLevel4: return "Sacrifices IV"
        case .sacrificesLevel5: return "Sacrifices V"
        case .sacrificesPower: return "Sacrifice Power"
        case .sacrificesPowerLevel2: return "Sacrifice Power II"
        case .sacrificesPowerLevel3: return "Sacrifice Power III"
        case .sacrificesPowerLevel4: return "Sacrifice Power IV"
        case .sacrificesPowerLevel5: return "Sacrifice Power V"
        case .artifactSlot: return "Artifact Slot"
        case .artifactSlotLevel2: return "Artifact Slot II"
        case .artifactSlotLevel3: return "Artifact Slot III"
        case .knowledgeSiphon: return "Knowledge Siphon"
        case .knowledgeSiphonLevel2: return "Knowledge Siphon II"
        case .knowledgeSiphonLevel3: return "Knowledge Siphon III"
        case .knowledgeSiphonLevel4: return "Knowledge Siphon IV"
        case .knowledgeSiphonLevel5: return "Knowledge Siphon V"
        case .offlineProgress: return "Offline Progress"
        case .offlineProgressLevel2: return "Offline Progress II"
        case .offlineProgressLevel3: return "Offline Progress III"
        case .offlineProgressLevel4: return "Offline Progress IV"
        case .offlineProgressLevel5: return "Offline Progress V"
        case .mapLocations: return "Locations"
        case .tradingPost: return "Trading Post"
        case .tradingPostLevel2: return "Trading Post II"
        case .tradingPostLevel3: return "Trading Post III"
        case .golems: return "Golems"
        case .golemMissionSlotsLevel2: return "Golem Missions II"
        case .golemMissionSlotsLevel3: return "Golem Missions III"
        case .golemMissionSlotsLevel4: return "Golem Missions IV"
        case .golemMissionSlotsLevel5: return "Golem Missions V"
        case .crafting: return "Crafting"
        }
    }

    public var description: String {
        switch self {
        case .portalUnlocked: return "Opens the portal’s upgrade paths."
        case .portalAutomation: return "Automatically pulls items out of the portal."
        case .researchLab: return "Unlocks the Research lab."
        case .sacrifices: return "Unlocks the Sacrifices feature."
        case .artifactSlot: return "Unlocks one equipped artifact slot."
        case .artifactSlotLevel2: return "Unlocks a second equipped artifact slot."
        case .artifactSlotLevel3: return "Unlocks a third equipped artifact slot."
        case .mapLocations: return "Unlocks pointing the portal at specific locations"
        case .tradingPost: return "Unlocks the Trading Post in the warehouse."
        case .tradingPostLevel2: return "Adds 1 extra trade offer and improves conversion rates."
        case .tradingPostLevel3: return "Adds 1 extra trade offer and improves conversion rates."
        case .golems: return "Unlocks the Golems tab."
        case .golemMissionSlotsLevel2: return "Adds a second concurrent golem mission."
        case .golemMissionSlotsLevel3: return "Adds a third concurrent golem mission."
        case .golemMissionSlotsLevel4: return "Adds a fourth concurrent golem mission."
        case .golemMissionSlotsLevel5: return "Adds a fifth concurrent golem mission."
        case .crafting:
            return "Unlocks the Equipment tab in the warehouse and the chance to find recipes when sacrificing."
        default:
            return self.bonus?.text ?? "TODO: Set manual description or add bonus"
        }
    }

    /// Items required to purchase this upgrade (item and quantity per line).
    public var cost: [UpgradeCostItem] {
        switch self {
        case .portalUnlocked: return []
        case .portalAutomation: return [
            .init(item: .gear, quantity: 1),
            .init(item: .copperFlorin, quantity: 1),
        ]
        case .portalAutomationLevel2: return [
            .init(item: .gear, quantity: 2),
            .init(item: .copperFlorin, quantity: 5),
        ]
        case .portalAutomationLevel3: return [
            .init(item: .gear, quantity: 4),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .portalAutomationLevel4: return [
            .init(item: .gear, quantity: 6),
            .init(item: .silverFlorin, quantity: 4),
        ]
        case .portalAutomationLevel5: return [
            .init(item: .gear, quantity: 8),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .portalDuplication: return [
            .init(item: .gear, quantity: 2),
            .init(item: .copperFlorin, quantity: 5),
        ]
        case .portalDuplicationLevel2: return [
            .init(item: .gear, quantity: 4),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .portalDuplicationLevel3: return [
            .init(item: .gear, quantity: 6),
            .init(item: .silverFlorin, quantity: 4),
        ]
        case .portalDuplicationLevel4: return [
            .init(item: .gear, quantity: 8),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .portalDuplicationLevel5: return [
            .init(item: .gear, quantity: 10),
            .init(item: .goldFlorin, quantity: 4),
        ]
        case .researchLab: return [
            .init(item: .potionFlask, quantity: 1),
            .init(item: .copperFlorin, quantity: 1),
        ]
        case .researchLabLevel2: return [
            .init(item: .potionFlask, quantity: 2),
            .init(item: .lens, quantity: 2),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .researchLabLevel3: return [
            .init(item: .potionFlask, quantity: 4),
            .init(item: .lens, quantity: 3),
            .init(item: .goldFlorin, quantity: 1),
        ]
        case .researchLabLevel4: return [
            .init(item: .potionFlask, quantity: 6),
            .init(item: .lens, quantity: 4),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .researchLabLevel5: return [
            .init(item: .potionFlask, quantity: 8),
            .init(item: .lens, quantity: 5),
            .init(item: .goldFlorin, quantity: 3),
        ]
        case .sacrifices: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .copperFlorin, quantity: 3),
        ]
        case .sacrificesLevel2: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .copperFlorin, quantity: 5),
        ]
        case .sacrificesLevel3: return [
            .init(item: .humanSkull, quantity: 2),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .sacrificesLevel4: return [
            .init(item: .humanSkull, quantity: 3),
            .init(item: .silverFlorin, quantity: 4),
        ]
        case .sacrificesLevel5: return [
            .init(item: .humanSkull, quantity: 4),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .sacrificesPower: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .copperFlorin, quantity: 5),
        ]
        case .sacrificesPowerLevel2: return [
            .init(item: .humanSkull, quantity: 2),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .sacrificesPowerLevel3: return [
            .init(item: .humanSkull, quantity: 3),
            .init(item: .silverFlorin, quantity: 4),
        ]
        case .sacrificesPowerLevel4: return [
            .init(item: .humanSkull, quantity: 4),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .sacrificesPowerLevel5: return [
            .init(item: .humanSkull, quantity: 5),
            .init(item: .goldFlorin, quantity: 4),
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
        case .offlineProgress: return [
            .init(item: .gear, quantity: 2),
            .init(item: .copperFlorin, quantity: 5),
        ]
        case .offlineProgressLevel2: return [
            .init(item: .gear, quantity: 4),
            .init(item: .silverFlorin, quantity: 2),
        ]
        case .offlineProgressLevel3: return [
            .init(item: .gear, quantity: 6),
            .init(item: .silverFlorin, quantity: 4),
        ]
        case .offlineProgressLevel4: return [
            .init(item: .gear, quantity: 8),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .offlineProgressLevel5: return [
            .init(item: .gear, quantity: 10),
            .init(item: .goldFlorin, quantity: 4),
        ]
        case .mapLocations: return [
            .init(item: .mapFragment, quantity: 5),
            .init(item: .silverFlorin, quantity: 10),
        ]
        case .tradingPost: return [
            .init(item: .merchantSigil, quantity: 2),
            .init(item: .goldFlorin, quantity: 5),
        ]
        case .tradingPostLevel2: return [
            .init(item: .merchantSigil, quantity: 10),
            .init(item: .goldFlorin, quantity: 10),
        ]
        case .tradingPostLevel3: return [
            .init(item: .merchantSigil, quantity: 25),
            .init(item: .goldFlorin, quantity: 10), // TODO: Update to 
        ]
        case .golems: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .silverFlorin, quantity: 5),
        ]
        case .golemMissionSlotsLevel2: return [
            .init(item: .humanSkull, quantity: 1),
            .init(item: .silverFlorin, quantity: 8),
        ]
        case .golemMissionSlotsLevel3: return [
            .init(item: .humanSkull, quantity: 2),
            .init(item: .lens, quantity: 1),
            .init(item: .silverFlorin, quantity: 12),
        ]
        case .golemMissionSlotsLevel4: return [
            .init(item: .humanSkull, quantity: 3),
            .init(item: .lens, quantity: 2),
            .init(item: .goldFlorin, quantity: 2),
        ]
        case .golemMissionSlotsLevel5: return [
            .init(item: .humanSkull, quantity: 4),
            .init(item: .lens, quantity: 3),
            .init(item: .goldFlorin, quantity: 5),
        ]
        case .crafting: return [
            .init(item: .gear, quantity: 3),
            .init(item: .potionFlask, quantity: 2),
            .init(item: .silverFlorin, quantity: 4),
        ]
        }
    }

    /// Optional gameplay bonus granted by this upgrade.
    public var bonus: Bonus? {
        switch self {
        case .researchLabLevel2, .researchLabLevel3, .researchLabLevel4, .researchLabLevel5:
            return .researchSpeed(10)
        case .portalAutomationLevel2, .portalAutomationLevel3, .portalAutomationLevel4, .portalAutomationLevel5:
            return .automaticItemCreationTimeReduction(50)
        case .portalDuplication, .portalDuplicationLevel2, .portalDuplicationLevel3, .portalDuplicationLevel4, .portalDuplicationLevel5:
            return .duplicateItemChance(2)
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
        case .sacrifices, .sacrificesLevel2, .sacrificesLevel3, .sacrificesLevel4, .sacrificesLevel5:
            return .sacrificeSlot(1)
        case .sacrificesPower, .sacrificesPowerLevel2, .sacrificesPowerLevel3, .sacrificesPowerLevel4, .sacrificesPowerLevel5:
            return .sacrificePower(10)
        case .offlineProgress, .offlineProgressLevel2, .offlineProgressLevel3, .offlineProgressLevel4, .offlineProgressLevel5:
            return .offlineTimeMinutes(60)
        case .golemMissionSlotsLevel2, .golemMissionSlotsLevel3, .golemMissionSlotsLevel4, .golemMissionSlotsLevel5:
            return .golemMissionSlots(1)
        default:
            return nil
        }
    }
}

extension PortalUpgrade {

    /// Parent in the tech tree; `nil` only for the root (`portalUnlocked`).
    public var treeParent: PortalUpgrade? {
        switch self {
        case .portalUnlocked:
            return nil
        case .portalAutomation, .researchLab, .sacrifices, .golems, .mapLocations, .artifactSlot:
            return .portalUnlocked
        case .portalAutomationLevel2:
            return .portalAutomation
        case .portalAutomationLevel3:
            return .portalAutomationLevel2
        case .portalAutomationLevel4:
            return .portalAutomationLevel3
        case .portalAutomationLevel5:
            return .portalAutomationLevel4
        case .portalDuplication:
            return .portalAutomation
        case .portalDuplicationLevel2:
            return .portalDuplication
        case .portalDuplicationLevel3:
            return .portalDuplicationLevel2
        case .portalDuplicationLevel4:
            return .portalDuplicationLevel3
        case .portalDuplicationLevel5:
            return .portalDuplicationLevel4
        case .researchLabLevel2:
            return .researchLab
        case .researchLabLevel3:
            return .researchLabLevel2
        case .researchLabLevel4:
            return .researchLabLevel3
        case .researchLabLevel5:
            return .researchLabLevel4
        case .knowledgeSiphon:
            return .researchLab
        case .sacrificesLevel2:
            return .sacrifices
        case .sacrificesLevel3:
            return .sacrificesLevel2
        case .sacrificesLevel4:
            return .sacrificesLevel3
        case .sacrificesLevel5:
            return .sacrificesLevel4
        case .sacrificesPower:
            return .sacrifices
        case .sacrificesPowerLevel2:
            return .sacrificesPower
        case .sacrificesPowerLevel3:
            return .sacrificesPowerLevel2
        case .sacrificesPowerLevel4:
            return .sacrificesPowerLevel3
        case .sacrificesPowerLevel5:
            return .sacrificesPowerLevel4
        case .artifactSlotLevel2:
            return .artifactSlot
        case .artifactSlotLevel3:
            return .artifactSlotLevel2
        case .knowledgeSiphonLevel2:
            return .knowledgeSiphon
        case .knowledgeSiphonLevel3:
            return .knowledgeSiphonLevel2
        case .knowledgeSiphonLevel4:
            return .knowledgeSiphonLevel3
        case .knowledgeSiphonLevel5:
            return .knowledgeSiphonLevel4
        case .offlineProgress:
            return .portalAutomation
        case .offlineProgressLevel2:
            return .offlineProgress
        case .offlineProgressLevel3:
            return .offlineProgressLevel2
        case .offlineProgressLevel4:
            return .offlineProgressLevel3
        case .offlineProgressLevel5:
            return .offlineProgressLevel4
        case .tradingPost:
            return .mapLocations
        case .tradingPostLevel2:
            return .tradingPost
        case .tradingPostLevel3:
            return .tradingPostLevel2
        case .golemMissionSlotsLevel2:
            return .golems
        case .golemMissionSlotsLevel3:
            return .golemMissionSlotsLevel2
        case .golemMissionSlotsLevel4:
            return .golemMissionSlotsLevel3
        case .golemMissionSlotsLevel5:
            return .golemMissionSlotsLevel4
        case .crafting:
            return .portalUnlocked
        }
    }

    /// Non–tree-parent requirements (achievements, items, locations). The tree edge is `upgradePurchased(treeParent)`.
    public var intrinsicUnlockRequirements: [UnlockRequirement] {
        switch self {
        case .portalUnlocked:
            return [.achievementUnlocked(.items10)]
        case .artifactSlot:
            return [.achievementUnlocked(.artifact1)]
        case .artifactSlotLevel2:
            return [.achievementUnlocked(.artifacts5)]
        case .knowledgeSiphon:
            return [.itemDiscovered(.book)]
        case .mapLocations:
            return [.itemDiscovered(.mapFragment)]
        case .tradingPost:
            return [.locationUnlocked(.semilTradingPost)]
        default:
            return []
        }
    }

    /// Requirements that must all be met before this upgrade becomes available.
    public var requirements: [UnlockRequirement] {
        if let parent = treeParent {
            return intrinsicUnlockRequirements + [.upgradePurchased(parent)]
        }
        return intrinsicUnlockRequirements
    }
}
