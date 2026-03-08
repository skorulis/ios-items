//Created by Alexander Skorulis on 10/2/2026.

import Foundation
import Knit
import KnitMacros

/// Class that creates new items
/// Functions in this class are non mutating and only return the result
final class ItemGeneratorService {
    
    private let mainStore: MainStore
    private let calculations: CalculationsService
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, calculations: CalculationsService) {
        self.mainStore = mainStore
        self.calculations = calculations
    }
    
    func recipeInfo(recipe: Recipe) -> RecipeInfo {
        return RecipeInfo(
            quality: qualityBonuses(recipe: recipe),
            essenceBoosts: essenceBonuses(recipe: recipe)
        )
    }
    
    func make(recipe: Recipe) -> Result {
        let info = recipeInfo(recipe: recipe)
        let quality = info.randomQuality()
        
        let options = BaseItem.allCases.filter { $0.quality == quality}
        
        let randomArray = RandomArray(items: options) { item in
            var chance: Double = 1
            for essence in item.essences {
                chance *= info.essenceBoosts[essence, default: 1]
            }
            return chance
        }
        
        guard let baseItem = randomArray.random else {
            fatalError("Could not find an appropriate item. \(quality.name)")
        }
        
        if let artifact = maybeConvertToArtifact(baseItem: baseItem) {
            return .artifact(artifact)
        }
        
        // Check if another item gets created based on double item chance
        if calculations.doubleItemChance(item: baseItem).check() {
            return .base(baseItem, 2)
        }
        
        return .base(baseItem, 1)
    }
    
    // MARK: - Private Functions
    
    private func maybeConvertToArtifact(baseItem: BaseItem) -> ArtifactInstance? {
        let itemLevel = mainStore.lab.currentLevel(item: baseItem)
        
        guard let type = baseItem.associatedArtifact,
              baseItem.availableResearch.isArtifactUnlocked(level: itemLevel),
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
    
    private func essenceBonuses(recipe: Recipe) -> [Essence: Double] {
        return recipe.items.reduce([:]) { partialResult, item in
            var mutableResult = partialResult
            for essence in item.essences {
                mutableResult[essence, default: 1] += 1
            }
            return mutableResult
        }
    }
    
    private var activeBonuses: [Bonus] {
        let fromAchievements = Achievement.allCases
            .filter { mainStore.achievements.unlocked.contains($0) }
            .compactMap(\.bonus)
        return fromAchievements + mainStore.portalUpgrades.bonuses
    }

    private func qualityBonuses(recipe: Recipe) -> [ItemQuality: Double] {
        let qualityBoosts = activeBonuses.qualityBoosts
        return Dictionary(
            uniqueKeysWithValues: ItemQuality.allCases.map { quality in
                let weight: Double
                switch quality {
                case .junk:
                    weight = 1
                case .common:
                    weight = 0.5 * Double(recipe.count(quality: .junk))
                case .good:
                    weight = 0.5 * Double(recipe.count(quality: .common))
                case .rare:
                    weight = 0.5 * Double(recipe.count(quality: .good))
                case .exceptional:
                    weight = 0.5 * Double(recipe.count(quality: .rare))
                }
                let boostPercent = Double(qualityBoosts[quality] ?? 0)
                let boostedWeight = weight * (1 + boostPercent / 100)
                return (quality, boostedWeight)
            }
        )
    }
}

// MARK: - Inner Types

extension ItemGeneratorService{
    
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
    
    enum Result {
        case base(BaseItem, Int)
        case artifact(ArtifactInstance)
    }
}

