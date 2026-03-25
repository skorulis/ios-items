// Created by Alexander Skorulis on 26/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

/// Performs equipment crafting against the warehouse.
final class CraftingService {

    private let mainStore: MainStore
    private let warehouseService: WarehouseService

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, warehouseService: WarehouseService) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
    }

    /// Crafts from `recipe` if the player can afford it and has inventory space.
    /// Returns the new instance, or `nil` if crafting did not run.
    func craft(recipe: EquipmentRecipe) -> EquipmentInstance? {
        let warehouse = mainStore.warehouse
        guard warehouse.equipment.count < 100 else { return nil }
        guard recipe.cost.allSatisfy({ line in
            warehouse.quantity(line.item) >= line.quantity
        }) else { return nil }

        for line in recipe.cost {
            warehouseService.remove(item: line.item, quantity: line.quantity)
        }

        let quality = randomQualityWeightedTowardJunk()
        let instance = recipe.item(quality: quality)
        warehouseService.add(equipment: instance)
        return instance
    }

    private func randomQualityWeightedTowardJunk() -> ItemQuality {
        let qualityArray = RandomArray(items: ItemQuality.allCases) { quality in
            switch quality {
            case .junk: return 50
            case .common: return 25
            case .good: return 15
            case .rare: return 9
            case .exceptional: return 1
            }
        }
        return qualityArray.random ?? .junk
    }
}
