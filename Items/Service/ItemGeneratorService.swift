//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Class that creates new items
/// Functions in this class are non mutating and only return the result
final class ItemGeneratorService {
    
    func make(recipe: Recipe) -> BaseItem {
        let qualityChance = createQualityChance(recipe: recipe)
        let randomArray = RandomArray(items: BaseItem.allCases) { item in
            return qualityChance[item.quality] ?? 0
        }
        
        return randomArray.random!
    }
    
    private func createQualityChance(recipe: Recipe) -> [ItemQuality: Double] {
        return [
            .junk: 1,
        ]
    }
}
