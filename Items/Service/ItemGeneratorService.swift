// Created by Alexander Skorulis on 10/2/2026.

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
    /// Essence boosts use only the plan’s essences (those unlocked by research).
    func sacrificeInfo(plan: SacrificePlan) -> SacrificeInfo {
        let sacrificeMultiplier = 1 + Double(activeBonuses.sacrificePowerPercent) / 100
        return SacrificeInfo(
            quality: qualityBonuses(plan: plan, sacrificeMultiplier: sacrificeMultiplier),
            essenceBoosts: plan.essenceMultipliers.mapValues { $0 * sacrificeMultiplier },
        )
    }

    /// Total percent chance to generate extra item results from active bonuses.
    func multipleItemsChancePercent() -> Int {
        activeBonuses.multipleItemsChancePercent
    }

    func makeAndStore(plan: SacrificePlan, allowArtifacts: Bool = true) -> [MakeItemResult] {
        let results = makeMultiple(plan: plan, allowArtifacts: allowArtifacts)
        for item in results {
            switch item {
            case let .base(baseItem, count):
                warehouseService.add(item: baseItem, count: count)
                mainStore.statistics.itemsCreated += Int64(count)
                if count > 1 {
                    mainStore.statistics.multipleItemCreations += 1
                }
            case let .artifact(artifact):
                warehouseService.add(artifact: artifact)
            }
            mainStore.mapLocations.incrementPullCount()
        }
        return results
    }

    /// Returns one or more independent item results for one sacrifice.
    /// `multipleItems` is treated as a percent chance for an extra result
    /// (e.g. 150% => 1 guaranteed extra + 50% chance for another).
    func makeMultiple(plan: SacrificePlan, allowArtifacts: Bool = true) -> [MakeItemResult] {
        let chancePercent = activeBonuses.multipleItemsChancePercent
        let chance = Chance(percent: chancePercent)
        let rolls = 1 + chance.bonus()
        return (0..<rolls).map { _ in make(plan: plan, allowArtifacts: allowArtifacts) }
    }

    func make(plan: SacrificePlan, allowArtifacts: Bool = true) -> MakeItemResult {
        let info = sacrificeInfo(plan: plan)
        let quality = info.randomQuality()

        let options = Ingredient.allCases.filter { item in
            guard item.quality == quality else { return false }

            // If the item is location-specific, only allow it when the current map location
            // explicitly lists it as one of its unique items.
            if item.locationSpecific {
                let currentLocation = mainStore.mapLocations.selected
                let allowedItems = currentLocation.details.uniqueItems
                return allowedItems.contains(item)
            }

            return true
        }

        let randomArray = RandomArray(items: options) { item in
            var chance: Double = 1
            for essence in item.essences {
                chance *= info.essenceBoosts[essence, default: 1]
            }
            // Higher Ingredient.rarity => larger weight => more likely to be rolled.
            chance *= item.rarity
            return chance
        }

        guard let baseItem = randomArray.random else {
            fatalError("Could not find an appropriate item. \(quality.name)")
        }

        if allowArtifacts, let artifact = maybeConvertToArtifact(baseItem: baseItem) {
            return .artifact(artifact)
        }

        let multiChance = calculations.multipleItemChanceFraction(item: baseItem)
        let guaranteedExtra = Int(multiChance)
        let remainder = multiChance - Double(guaranteedExtra)
        let extraFromRoll = remainder > 0 && Chance(remainder).check()
        let count = 1 + guaranteedExtra + (extraFromRoll ? 1 : 0)

        return .base(baseItem, count)
    }

    // MARK: - Private Functions

    private func maybeConvertToArtifact(baseItem: Ingredient) -> ArtifactInstance? {
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

    private var activeBonuses: [Bonus] {
        mainStore.activeBonuses
    }

    private func qualityBonuses(plan: SacrificePlan, sacrificeMultiplier: Double) -> [ItemQuality: Double] {
        let qualityBoosts = activeBonuses.qualityBoosts
        let sacrificeBoost = 0.5 * sacrificeMultiplier
        return Dictionary(
            uniqueKeysWithValues: ItemQuality.allCases.map { quality in
                let weight: Double
                switch quality {
                case .junk:
                    weight = 1
                case .common:
                    weight = sacrificeBoost * Double(plan.count(quality: .junk))
                case .good:
                    weight = sacrificeBoost * Double(plan.count(quality: .common))
                case .rare:
                    weight = sacrificeBoost * Double(plan.count(quality: .good))
                case .exceptional:
                    weight = sacrificeBoost * Double(plan.count(quality: .rare))
                }
                let boostPercent = Double(qualityBoosts[quality] ?? 0)
                let boostedWeight = (weight + (boostPercent / 100))
                return (quality, boostedWeight)
            }
        )
    }
}

// MARK: - Inner Types

extension ItemGeneratorService {

    struct SacrificeInfo {
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
