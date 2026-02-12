//Created by Alexander Skorulis on 12/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class RecipeListViewModel {
    
    var recipes: [Recipe] = []
    var warehouse: Warehouse
    
    var editingRecipe: Recipe?
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        warehouse = mainStore.warehouse
        
        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension RecipeListViewModel {
    
    func addRecipe() {
        recipes.append(.init(items: []))
    }
    
    func addItem(to recipe: Recipe) {
        self.editingRecipe = recipe
    }
    
    func addItem(recipe: Recipe, item: BaseItem) {
        let index = recipes.firstIndex(where: { $0.id == recipe.id})
        guard let index else { return }
        recipes[index].items.append(item)
    }
}
