//Created by Alexander Skorulis on 12/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class RecipeListViewModel: CoordinatorViewModel {
    
    var coordinator: ASKCoordinator.Coordinator?
    
    var recipes: [Recipe] {
        didSet {
            mainStore.recipes = recipes
        }
    }
    var warehouse: Warehouse
    
    var editingRecipe: Recipe?
    
    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        warehouse = mainStore.warehouse
        recipes = mainStore.recipes
        
        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Inner Types

extension RecipeListViewModel {
    enum Strings {
        static let helpText = """
        The Sacrifices screen lets you define rules for what items will be sacrificed on the next item generation.
        Each time an item is generated it will pick the first sacrifice option which has ingredients in your warehouse and consume them.
        Sacrificing low quality items helps to create specific higher quality ones.
        """
    }
}

// MARK: - Logic

extension RecipeListViewModel {
    
    func showInfo() {
        coordinator?.custom(overlay: .card, MainPath.dialog(Strings.helpText))
    }
    
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
    
    func delete(indexSet: IndexSet) {
        recipes.remove(atOffsets: indexSet)
    }
    
}

