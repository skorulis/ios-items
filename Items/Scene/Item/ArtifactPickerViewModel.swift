//Created by Alexander Skorulis on 7/3/2026.

import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class ArtifactPickerViewModel {

    let slot: Int

    private let mainStore: MainStore
    private let warehouseService: WarehouseService

    @Resolvable<BaseResolver>
    init(@Argument slot: Int, mainStore: MainStore, warehouseService: WarehouseService) {
        self.slot = slot
        self.mainStore = mainStore
        self.warehouseService = warehouseService
    }
}

// MARK: - Logic

extension ArtifactPickerViewModel {

    /// Discovered artifacts that are not already equipped in any slot.
    var availableArtifacts: [Artifact] {
        let warehouse = mainStore.warehouse
        let equipped = Set(warehouse.equippedSlots.values)
        return Artifact.allCases.filter { artifact in
            warehouse.artifactInstance(artifact) != nil && !equipped.contains(artifact)
        }
    }

    var warehouse: Warehouse {
        mainStore.warehouse
    }

    func select(artifact: ArtifactInstance) {
        warehouseService.equip(artifact.type, slot: slot)
    }
}
