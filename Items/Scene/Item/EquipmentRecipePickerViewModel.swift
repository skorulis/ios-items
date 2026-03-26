import Foundation
import Models

@Observable
final class EquipmentRecipePickerViewModel {
    private let mainStore: MainStore
    private let onRecipeSelected: (Int) -> Void

    init(mainStore: MainStore, onRecipeSelected: @escaping (Int) -> Void) {
        self.mainStore = mainStore
        self.onRecipeSelected = onRecipeSelected
    }

    var discoveredRecipes: [EquipmentRecipe] {
        EquipmentRecipe.allCases.filter { mainStore.warehouse.recipes.contains($0) }
    }

    func itemQuantity(_ item: Ingredient) -> Int {
        mainStore.warehouse.quantity(item)
    }

    func areAllIngredientsAvailable(for recipe: EquipmentRecipe) -> Bool {
        recipe.cost.allSatisfy { line in
            mainStore.warehouse.quantity(line.item) >= line.quantity
        }
    }

    func selectRecipe(at index: Int) {
        onRecipeSelected(index)
    }
}
