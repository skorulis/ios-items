import Foundation
import Models

/// Pure calculator for `UnlockRequirement` progress based on a snapshot of game state.
///
/// This intentionally takes dependencies as input values so it can be recreated cheaply
/// whenever `MainStore` updates.
final class UnlockRequirementCalculator {
    var warehouse: Warehouse
    var statistics: Statistics
    var lab: Laboratory
    var concepts: Concepts
    var portalUpgrades: PortalUpgrades
    var achievements: Achievements
    var mapLocations: MapLocations

    init(
        warehouse: Warehouse,
        statistics: Statistics,
        lab: Laboratory,
        concepts: Concepts,
        portalUpgrades: PortalUpgrades,
        achievements: Achievements,
        mapLocations: MapLocations
    ) {
        self.warehouse = warehouse
        self.statistics = statistics
        self.lab = lab
        self.concepts = concepts
        self.portalUpgrades = portalUpgrades
        self.achievements = achievements
        self.mapLocations = mapLocations
    }

    // swiftlint:disable:next cyclomatic_complexity
    func progressValue(requirement: UnlockRequirement) -> Int64 {
        switch requirement {
        case .itemsCreated:
            return statistics.itemsCreated
        case .itemsSacrificed:
            return statistics.itemsSacrificed
        case .multipleItemCreations:
            return statistics.multipleItemCreations
        case .tradesCompleted:
            return statistics.tradesCompleted
        case .itemsDiscovered:
            return Int64(
                Ingredient.allCases.filter { item in
                    warehouse.hasDiscovered(item)
                }.count
            )
        case .totalResearch:
            return Int64(lab.totalLevels)
        case .maxResearchLevel:
            return Int64(lab.maxResearchLevel)
        case .commonItemsCreated:
            return Int64(warehouse.totalItemsCollected { $0.quality == .common })
        case .locationSpecificItemsDiscovered:
            return Int64(
                Ingredient.locationSpecificItems.filter { item in
                    warehouse.hasDiscovered(item)
                }.count
            )
        case let .itemDiscovered(item):
            return warehouse.hasDiscovered(item) ? 1 : 0
        case .essencesUnlocked:
            return Int64(concepts.essences.count)
        case let .essenceUnlocked(essence):
            return concepts.essences.contains(essence) ? 1 : 0
        case .artifactsUnlocked:
            return Int64(Artifact.allCases.filter { warehouse.quality($0) != nil }.count)
        case let .artifactUnlocked(artifact):
            return warehouse.quality(artifact) != nil ? 1 : 0
        case let .artifactQualityUnlocked(quality):
            return warehouse.hasArtifact(atLeast: quality) ? 1 : 0
        case let .upgradePurchased(upgrade):
            return portalUpgrades.purchased.contains(upgrade) ? 1 : 0
        case .upgradesPurchased:
            return Int64(portalUpgrades.purchased.count)
        case let .achievementUnlocked(achievement):
            return achievements.unlocked.contains(achievement) ? 1 : 0
        case let .locationUnlocked(location):
            return mapLocations.isUnlocked(location) ? 1 : 0
        }
    }

    func progressTotal(requirement: UnlockRequirement) -> Int64 {
        switch requirement {
        case let .itemsCreated(count),
            let .itemsSacrificed(count),
            let .multipleItemCreations(count),
            let .tradesCompleted(count),
            let .itemsDiscovered(count),
            let .totalResearch(count),
            let .maxResearchLevel(count),
            let .commonItemsCreated(count),
            let .essencesUnlocked(count),
            let .artifactsUnlocked(count),
            let .locationSpecificItemsDiscovered(count):
            return count

        case let .upgradesPurchased(count):
            return count
        case .itemDiscovered,
            .essenceUnlocked,
            .artifactUnlocked,
            .artifactQualityUnlocked,
            .upgradePurchased,
            .achievementUnlocked,
            .locationUnlocked:
            return 1
        }
    }

    func isComplete(requirement: UnlockRequirement) -> Bool {
        progressValue(requirement: requirement) >= progressTotal(requirement: requirement)
    }
}
