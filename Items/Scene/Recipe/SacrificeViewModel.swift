//Created by Alexander Skorulis on 11/3/2026.

import ASKCore
import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class SacrificeViewModel: CoordinatorViewModel {

    weak var coordinator: ASKCoordinator.Coordinator?

    var model: SacrificeView.Model

    /// When non-nil, sheet shows ItemPicker for this slot index.
    var editingSlot: SacrificeSlotEdit?

    private let mainStore: MainStore
    private let recipeService: RecipeService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, recipeService: RecipeService) {
        self.mainStore = mainStore
        self.recipeService = recipeService
        self.model = .init(sacrificesEnabled: mainStore.recipes.sacrificesEnabled, warehouse: mainStore.warehouse)

        mainStore.$warehouse.delayedChange().sink { [unowned self] in
            self.model.warehouse = $0
            self.syncModel()
        }
        .store(in: &cancellables)

        mainStore.$recipes.delayedChange().sink { [unowned self] in
            self.model.sacrificesEnabled = $0.sacrificesEnabled
            self.syncModel()
        }
        .store(in: &cancellables)

        mainStore.$portalUpgrades.delayedChange().sink { [unowned self] _ in
            self.syncModel()
        }
        .store(in: &cancellables)

        // Match store immediately; sinks only run on subsequent changes.
        syncModel()
    }

    private func syncModel() {
        model.consumptionPlan = recipeService.sacrificeConsumptionPlan()
        model.slotItems = mainStore.recipes.sacrificeConfig.slots
        model.unlockedSlotCount = mainStore.portalUpgrades.bonuses
            .map(\.sacrificeSlotBoost)
            .reduce(0, +)
    }
}

// MARK: - Logic

extension SacrificeViewModel {

    func setSacrificesEnabled(_ enabled: Bool) {
        mainStore.recipes.sacrificesEnabled = enabled
        syncModel()
    }

    func openPicker(forSlot index: Int) {
        guard index >= 0, index < model.unlockedSlotCount else { return }
        editingSlot = SacrificeSlotEdit(index: index)
    }

    func clearSlot(index: Int) {
        guard index < model.unlockedSlotCount else { return }
        var config = mainStore.recipes.sacrificeConfig
        config.setSlot(index: index, item: nil)
        mainStore.recipes.sacrificeConfig = config
        syncModel()
    }

    func assignItem(at index: Int, item: BaseItem) {
        guard index < model.unlockedSlotCount else { return }
        var config = mainStore.recipes.sacrificeConfig
        config.setSlot(index: index, item: item)
        mainStore.recipes.sacrificeConfig = config
        editingSlot = nil
        syncModel()
    }
}

// MARK: - Sheet item

/// Identifiable wrapper so `sheet(item:)` can present the picker for one slot.
struct SacrificeSlotEdit: Identifiable {
    let index: Int
    var id: Int { index }
}
