// Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

/// Service that evaluates unlock requirements against current game state.
/// Use this instead of AchievementService when you only need to check requirements.
final class UnlockRequirementService {

    private let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }

    func progressValue(requirement: UnlockRequirement) -> Int64 {
        switch requirement {
        case .itemsCreated:
            return mainStore.statistics.itemsCreated
        case .itemsSacrificed:
            return mainStore.statistics.itemsSacrificed
        case .doubleItemCreations:
            return mainStore.statistics.doubleItemCreations
        case .totalResearch:
            return Int64(mainStore.lab.totalLevels)
        case .maxResearchLevel:
            return Int64(mainStore.lab.maxResearchLevel)
        case .commonItemsCreated:
            return Int64(mainStore.warehouse.totalItemsCollected { $0.quality == .common })
        case let .itemDiscovered(item):
            return mainStore.warehouse.hasDiscovered(item) ? 1 : 0
        case .essencesUnlocked:
            return Int64(mainStore.concepts.essences.count)
        case let .essenceUnlocked(essence):
            return mainStore.concepts.essences.contains(essence) ? 1 : 0
        case .artifactsUnlocked:
            return Int64(Artifact.allCases.filter { mainStore.warehouse.quality($0) != nil }.count)
        case let .artifactUnlocked(artifact):
            return mainStore.warehouse.quality(artifact) != nil ? 1 : 0
        case let .upgradePurchased(upgrade):
            return mainStore.portalUpgrades.purchased.contains(upgrade) ? 1 : 0
        case .upgradesPurchased:
            return Int64(mainStore.portalUpgrades.purchased.count)
        case let .achievementUnlocked(achievement):
            return mainStore.achievements.unlocked.contains(achievement) ? 1 : 0
        }
    }

    func progressTotal(requirement: UnlockRequirement) -> Int64 {
        switch requirement {
        case let .itemsCreated(count),
             let .itemsSacrificed(count),
             let .doubleItemCreations(count),
             let .totalResearch(count),
             let .maxResearchLevel(count),
             let .commonItemsCreated(count),
             let .essencesUnlocked(count),
             let .artifactsUnlocked(count):
            return count

        case let .upgradesPurchased(count):
            return count
        case .itemDiscovered,
             .essenceUnlocked,
             .artifactUnlocked,
             .upgradePurchased,
             .achievementUnlocked:
            return 1
        }
    }

    func isComplete(requirement: UnlockRequirement) -> Bool {
        progressValue(requirement: requirement) >= progressTotal(requirement: requirement)
    }
}
