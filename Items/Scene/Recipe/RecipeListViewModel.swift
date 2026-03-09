//Created by Alexander Skorulis on 12/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class RecipeListViewModel: CoordinatorViewModel {
    
    var coordinator: ASKCoordinator.Coordinator?
    
    private(set) var recipes: [Recipe]
    var warehouse: Warehouse
    var sacrificesEnabled: Bool = true
    
    var editingRecipe: Recipe?
    
    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        warehouse = mainStore.warehouse
        recipes = mainStore.recipes.list
        sacrificesEnabled = mainStore.recipes.sacrificesEnabled

        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)

        mainStore.$recipes.sink { [unowned self] in
            self.recipes = $0.list
            self.sacrificesEnabled = $0.sacrificesEnabled
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension RecipeListViewModel {
    
    func showInfo() {
        coordinator?.custom(overlay: .card, MainPath.dialog(HelpStrings.recipeList))
    }
    
    func addRecipe() {
        let newRecipe = Recipe(items: [])
        mainStore.recipes.list.append(newRecipe)
        editingRecipe = newRecipe
    }
    
    func addItem(to recipe: Recipe) {
        self.editingRecipe = recipe
    }
    
    func addItem(recipe: Recipe, item: BaseItem) {
        let index = recipes.firstIndex(where: { $0.id == recipe.id})
        guard let index else { return }
        mainStore.recipes.list[index].items.append(item)
    }

    func removeItem(_ item: BaseItem, from recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        mainStore.recipes.list[index].items.removeAll { $0 == item }
    }

    func showDetails(for recipe: Recipe) {
        coordinator?.custom(overlay: .card, MainPath.recipeDetail(recipe))
    }
    
    func delete(indexSet: IndexSet) {
        mainStore.recipes.list.remove(atOffsets: indexSet)
    }

    func setSacrificesEnabled(_ enabled: Bool) {
        mainStore.recipes.sacrificesEnabled = enabled
    }
    
    func moveRecipes(fromOffsets source: IndexSet, toOffset destination: Int) {
        mainStore.recipes.list.move(fromOffsets: source, toOffset: destination)
    }

}

