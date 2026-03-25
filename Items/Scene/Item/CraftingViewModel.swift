import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models

@Observable
final class CraftingViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    private let mainStore: MainStore
    private let craftingService: CraftingService

    private var cancellables: Set<AnyCancellable> = []

    private(set) var warehouse: Warehouse

    /// Selected recipe index into `discoveredRecipes`, updated by this screen or the recipe picker overlay.
    private(set) var selectedRecipeIndex: Int?

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        craftingService: CraftingService
    ) {
        self.mainStore = mainStore
        self.craftingService = craftingService
        self.warehouse = mainStore.warehouse

        mainStore.$warehouse
            .sink { [unowned self] in
                self.warehouse = $0
            }
            .store(in: &cancellables)
    }

    var discoveredRecipes: [EquipmentRecipe] {
        EquipmentRecipe.allCases.filter { warehouse.recipes.contains($0) }
    }

    var selectedRecipe: EquipmentRecipe? {
        guard let selectedRecipeIndex else { return nil }
        guard selectedRecipeIndex >= 0, selectedRecipeIndex < discoveredRecipes.count else { return nil }
        return discoveredRecipes[selectedRecipeIndex]
    }

    var hasInventorySpace: Bool {
        // Maximum 100 equipment instances in the inventory.
        warehouse.equipment.count < 100
    }

    private func canAfford(_ recipe: EquipmentRecipe) -> Bool {
        recipe.cost.allSatisfy { line in
            warehouse.quantity(line.item) >= line.quantity
        }
    }

    var canCraft: Bool {
        guard let recipe = selectedRecipe else { return false }
        return hasInventorySpace && canAfford(recipe)
    }

    var craftDisabledReason: String? {
        guard let recipe = selectedRecipe else { return "Select a recipe to craft." }
        guard hasInventorySpace else { return "No inventory space available." }
        guard canAfford(recipe) else { return "Missing required materials." }
        return nil
    }

    func selectRecipe(at index: Int) {
        selectedRecipeIndex = index
    }

    func showRecipePicker() {
        coordinator?.custom(
            overlay: .card,
            MainPath.equipmentRecipePicker(
                presentationID: UUID(),
                onRecipeSelected: { [weak self] index in
                    self?.selectRecipe(at: index)
                }
            )
        )
    }

    func craft() {
        guard canCraft, let recipe = selectedRecipe else { return }
        guard let instance = craftingService.craft(recipe: recipe) else { return }

        coordinator?.custom(
            overlay: .card,
            MainPath.dialog("Crafted \(instance.displayName)")
        )
    }
}
