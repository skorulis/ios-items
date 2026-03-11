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

    /// Removes one warehouse unit per entry in the plan’s `consumedItems` order.
    func consumePlan(_ plan: SacrificePlan) {
        for item in plan.consumedItems {
            mainStore.warehouse.remove(item: item, quantity: 1)
        }
    }
    
}
