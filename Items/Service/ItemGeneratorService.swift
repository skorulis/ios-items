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
    
    func make(recipe: Recipe) -> Result {
        let qualityChance = createQualityChance(recipe: recipe)
        let essenceBonuses = essenceBonuses(recipe: recipe)
        let randomArray = RandomArray(items: BaseItem.allCases) { item in
            var chance = qualityChance[item.quality] ?? 0
            for essence in item.essences {
                chance *= essenceBonuses[essence, default: 1]
            }
            return chance
        }
        
        let baseItem = randomArray.random!
        
        if let artifact = maybeConvertToArtifact(baseItem: baseItem) {
            return .artifact(artifact)
        }
        
        // Check if another item gets created based on double item chance
        let chance = calculations.doubleItemChance(item: baseItem)
        let roll = Double.random(in: 0...1)
        if roll < chance {
            return .base(baseItem, 2)
        }
        
        return .base(baseItem, 1)
    }
    
    private func maybeConvertToArtifact(baseItem: BaseItem) -> ArtifactInstance? {
        guard let type = baseItem.associatedArtifact,
              let targetQuality = mainStore.warehouse.nextArtifactQuality(artifact: type)
        else {
            return nil
        }
        
        let chance = calculations.artifactChance(quality: targetQuality)
        guard Double.random(in: 0..<1) < chance else {
            return nil
        }
        
        return ArtifactInstance(type: type, quality: targetQuality)
    }
    
    private func createQualityChance(recipe: Recipe) -> [ItemQuality: Double] {
        return [
            .junk: 1,
            .common: 0.5 * Double(recipe.count(quality: .junk)),
            .good: 0.5 * Double(recipe.count(quality: .common)),
            .rare: 0.5 * Double(recipe.count(quality: .good)),
            .exceptional: 0.5 * Double(recipe.count(quality: .rare)),
        ]
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
}

// MARK: - Inner Types

extension ItemGeneratorService{
    
    enum Result {
        case base(BaseItem, Int)
        case artifact(ArtifactInstance)
    }
}

