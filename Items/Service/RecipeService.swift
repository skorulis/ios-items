//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import Knit
import KnitMacros

final class RecipeService {
    
    private let mainStore: MainStore
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
    
    // Pick the next recipe that can be used and consume the items
    func consumeRecipe(_ recipe: Recipe) {
        for item in recipe.items {
            mainStore.warehouse.remove(item: item, quantity: 1)
        }
    }
    
    // Find the next recipe which can be used (
    func nextAvailable() -> Recipe {
        for recipe in mainStore.recipes {
            let possible = recipe.items.allSatisfy { mainStore.warehouse.quantity($0) > 0 }
            if possible { return recipe }
        }
        
        // Use a default recipe
        return .init(items: [])
    }
}
