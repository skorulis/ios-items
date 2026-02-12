//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class CreationViewModel {
    
    private let itemGeneratorService: ItemGeneratorService
    private let mainStore: MainStore
    private let recipeService: RecipeService
    
    private(set) var createdItem: BaseItem?
    
    @Resolvable<BaseResolver>
    init(itemGeneratorService: ItemGeneratorService, mainStore: MainStore, recipeService: RecipeService) {
        self.itemGeneratorService = itemGeneratorService
        self.mainStore = mainStore
        self.recipeService = recipeService
    }
}

// MARK: - Logic

extension CreationViewModel {
    
    func make() {
        let recipe = recipeService.nextAvailable()
        recipeService.consumeRecipe(recipe)
        let item = itemGeneratorService.make(recipe: recipe)
        mainStore.warehouse.add(item: item)
        
        mainStore.statistics.itemsCreated += 1
        mainStore.statistics.itemsDestroyed += Int64(recipe.items.count)
        
        self.createdItem = item
    }
    
}
