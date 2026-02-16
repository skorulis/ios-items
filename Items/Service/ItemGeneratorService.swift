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
        
        // TODO: Check if another item gets created
        
        return .base(baseItem, 1)
    }
    
    private func maybeConvertToArtifact(baseItem: BaseItem) -> ArtifactInstance? {
        guard let type = baseItem.associatedArtifact else {
            return nil
        }
        // TODO: Do check to calculate quality
        let quality = ItemQuality.junk
        let instance = ArtifactInstance(type: type, quality: quality)
        guard !mainStore.warehouse.has(artifact: instance) else {
            return nil
        }
        return instance
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
