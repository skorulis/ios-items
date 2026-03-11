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
    private let itemGeneratorService: ItemGeneratorService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, itemGeneratorService: ItemGeneratorService) {
        self.mainStore = mainStore
        self.itemGeneratorService = itemGeneratorService
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
    }

    private func syncModel() {
        model.consumptionPlan = itemGeneratorService.sacrificeConsumptionPlan(config: mainStore.recipes.sacrificeConfig)
        model.slotItems = mainStore.recipes.sacrificeConfig.slots
        
    }
}

// MARK: - Logic

extension SacrificeViewModel {

    func setSacrificesEnabled(_ enabled: Bool) {
        mainStore.recipes.sacrificesEnabled = enabled
        syncModel()
    }

    func openPicker(forSlot index: Int) {
        guard index >= 0, index < SacrificeConfig.slotCount else { return }
        editingSlot = SacrificeSlotEdit(index: index)
    }

    func clearSlot(index: Int) {
        var config = mainStore.recipes.sacrificeConfig
        config.setSlot(index: index, item: nil)
        mainStore.recipes.sacrificeConfig = config
        syncModel()
    }

    func assignItem(at index: Int, item: BaseItem) {
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
