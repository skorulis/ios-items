import Foundation
import Knit
import KnitMacros
import Models

@Observable
final class EquipmentRecipePickerViewModel {
    private let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }

    var discoveredRecipes: [EquipmentRecipe] {
        EquipmentRecipe.allCases.filter { mainStore.warehouse.recipes.contains($0) }
    }

    var selectedRecipeIndex: Int? {
        mainStore.craftingSelectedRecipeIndex
    }

    func selectRecipe(at index: Int) {
        mainStore.craftingSelectedRecipeIndex = index
    }
}

