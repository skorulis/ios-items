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
    private let calculations: CalculationsService

    private var cancellables: Set<AnyCancellable> = []

    private(set) var warehouse: Warehouse

    /// Selected recipe index into `discoveredRecipes`, updated by this screen or the recipe picker overlay.
    private(set) var selectedRecipeIndex: Int?

    /// Active craft animation (portal-style particle timing).
    private(set) var craftingInProgress: CraftingInProgress?

    /// Last successfully crafted piece, shown in the output slot until the recipe changes.
    private(set) var lastCraftedEquipment: EquipmentInstance?

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        craftingService: CraftingService,
        calculations: CalculationsService
    ) {
        self.mainStore = mainStore
        self.craftingService = craftingService
        self.calculations = calculations
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

    var isCrafting: Bool { craftingInProgress != nil }

    var canCraft: Bool {
        guard let recipe = selectedRecipe else { return false }
        return !isCrafting && hasInventorySpace && canAfford(recipe)
    }

    var craftDisabledReason: String? {
        guard hasInventorySpace else { return "No inventory space available." }
        return nil
    }

    func selectRecipe(at index: Int) {
        selectedRecipeIndex = index
        lastCraftedEquipment = nil
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
        Task { await craftAsync() }
    }

    private func craftAsync() async {
        guard !isCrafting, let recipe = selectedRecipe else { return }
        guard hasInventorySpace, canAfford(recipe) else { return }

        let duration = TimeInterval(calculations.itemCreationMilliseconds) / 1000
        craftingInProgress = CraftingInProgress(id: UUID(), duration: duration, recipe: recipe)

        let ms = Int(calculations.itemCreationMilliseconds)
        try? await Task.sleep(for: .milliseconds(ms))

        craftingInProgress = nil

        guard let instance = craftingService.craft(recipe: recipe) else {
            coordinator?.custom(
                overlay: .card,
                MainPath.dialog("Could not complete crafting. Check materials and inventory space.")
            )
            return
        }

        lastCraftedEquipment = instance
    }

    func showEquipmentDetails(for instance: EquipmentInstance) {
        coordinator?.custom(overlay: .card, MainPath.equipmentDetails(instance))
    }
}

// MARK: - Crafting animation state

struct CraftingInProgress: Equatable {
    let id: UUID
    let duration: TimeInterval
    let recipe: EquipmentRecipe
}
