//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Class that creates new items
/// Functions in this class are non mutating and only return the result
final class ItemGeneratorService {
    
    func make(recipe: Recipe) -> BaseItem {
        return BaseItem.allCases.randomElement()!
    }
}
