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

    func selectRecipe(at index: Int) {
        onRecipeSelected(index)
    }
}
