//Created by Alexander Skorulis on 10/2/2026.

import Foundation
import Knit
import KnitMacros
import Models

/// Class that creates new items
/// Functions in this class are non mutating and only return the result
final class ItemGeneratorService {

    private let mainStore: MainStore
    private let calculations: CalculationsService
    private let warehouseService: WarehouseService

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, calculations: CalculationsService, warehouseService: WarehouseService) {
        self.mainStore = mainStore
        self.calculations = calculations
        self.warehouseService = warehouseService
    }

    /// Quality/essence weights derived from the items that would be consumed for this plan.
    func recipeInfo(plan: SacrificePlan) -> RecipeInfo {
        let items = plan.consumedItems
        return RecipeInfo(
            quality: qualityBonuses(plan: plan),
            essenceBoosts: essenceBonuses(items: items)
        )
    }

    func makeAndStore(plan: SacrificePlan) -> MakeItemResult {
        let item = make(plan: plan)
        switch item {
        case let .base(baseItem, count):
            warehouseService.add(item: baseItem, count: count)

            mainStore.statistics.itemsCreated += Int64(count)
            if count > 1 {
                mainStore.statistics.doubleItemCreations += 1
            }
        case let .artifact(artifact):
            warehouseService.add(artifact: artifact)
        }
        return item
    }

    func make(plan: SacrificePlan) -> MakeItemResult {
        let info = recipeInfo(plan: plan)
        let quality = info.randomQuality()

        let options = BaseItem.allCases.filter { $0.quality == quality }

        let randomArray = RandomArray(items: options) { item in
            var chance: Double = 1
            for essence in item.essences {
                chance *= info.essenceBoosts[essence, default: 1]
            }
            // Higher BaseItem.rarity => larger weight => more likely to be rolled.
            chance *= item.rarity
            return chance
        }

        guard let baseItem = randomArray.random else {
            fatalError("Could not find an appropriate item. \(quality.name)")
        }

        if let artifact = maybeConvertToArtifact(baseItem: baseItem) {
            return .artifact(artifact)
        }

        if calculations.doubleItemChance(item: baseItem).check() {
            return .base(baseItem, 2)
        }

        return .base(baseItem, 1)
    }

    // MARK: - Private Functions

    private func maybeConvertToArtifact(baseItem: BaseItem) -> ArtifactInstance? {
        let itemLevel = mainStore.lab.currentLevel(item: baseItem)

        guard let type = baseItem.associatedArtifact,
              mainStore.warehouse.hasDiscovered(baseItem),
              let targetQuality = mainStore.warehouse.nextArtifactQuality(artifact: type)
        else {
            return nil
        }

        let chance = calculations.artifactChance(quality: targetQuality, researchLevel: itemLevel)
        guard chance.check() else {
            return nil
        }

        return ArtifactInstance(type: type, quality: targetQuality)
    }

    private func essenceBonuses(items: [BaseItem]) -> [Essence: Double] {
        items.reduce(into: [:]) { partialResult, item in
            for essence in item.essences {
                partialResult[essence, default: 1] += 1
            }
        }
    }

    private var activeBonuses: [Bonus] {
        let fromAchievements = Achievement.allCases
            .filter { mainStore.achievements.unlocked.contains($0) }
            .compactMap(\.bonus)
        return fromAchievements + mainStore.portalUpgrades.bonuses
    }

    private func qualityBonuses(plan: SacrificePlan) -> [ItemQuality: Double] {
        let qualityBoosts = activeBonuses.qualityBoosts
        return Dictionary(
            uniqueKeysWithValues: ItemQuality.allCases.map { quality in
                let weight: Double
                switch quality {
                case .junk:
                    weight = 1
                case .common:
                    weight = 0.5 * Double(plan.count(quality: .junk))
                case .good:
                    weight = 0.5 * Double(plan.count(quality: .common))
                case .rare:
                    weight = 0.5 * Double(plan.count(quality: .good))
                case .exceptional:
                    weight = 0.5 * Double(plan.count(quality: .rare))
                }
                let boostPercent = Double(qualityBoosts[quality] ?? 0)
                let boostedWeight = weight + (boostPercent / 100)
                return (quality, boostedWeight)
            }
        )
    }
}

// MARK: - Inner Types

extension ItemGeneratorService {

    struct RecipeInfo {
        let quality: [ItemQuality: Double]
        let essenceBoosts: [Essence: Double]

        fileprivate func randomQuality() -> ItemQuality {
            let randomArray = RandomArray(items: ItemQuality.allCases) {
                quality[$0] ?? 0
            }
            return randomArray.random ?? .junk
        }
    }
}
