//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Class that creates new items
/// Functions in this class are non mutating and only return the result
final class ItemGeneratorService {
    
    func make(recipe: Recipe) -> BaseItem {
        let qualityChance = createQualityChance(recipe: recipe)
        let essenceBonuses = essenceBonuses(recipe: recipe)
        let randomArray = RandomArray(items: BaseItem.allCases) { item in
            var chance = qualityChance[item.quality] ?? 0
            for essence in item.essences {
                chance *= essenceBonuses[essence, default: 1]
            }
            return chance
        }
        
        return randomArray.random!
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
