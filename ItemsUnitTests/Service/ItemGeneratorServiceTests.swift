//Created by Alexander Skorulis on 11/3/2026.

@testable import Items
import Foundation
import Knit
import Models
import Testing

@MainActor
struct ItemGeneratorServiceTests {

    // MARK: - sacrificeConsumptionPlan

    @Test
    func sacrificeConsumptionPlan_emptyConfig_allSlotsNil() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let config = SacrificeConfig(slots: [:])

        let plan = service.sacrificeConsumptionPlan(config: config)

        for index in 0..<SacrificeConfig.slotCount {
            #expect(plan[index] == nil)
        }
    }

    @Test
    func sacrificeConsumptionPlan_singleSlot_withStock_returnsItem() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 1)

        let config = SacrificeConfig(slots: [0: .apple])
        let plan = service.sacrificeConsumptionPlan(config: config)

        #expect(plan[0] == .apple)
        for index in 1..<SacrificeConfig.slotCount {
            #expect(plan[index] == nil)
        }
    }

    @Test
    func sacrificeConsumptionPlan_singleSlot_withoutStock_returnsNil() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        // Do not add apple — quantity 0

        let config = SacrificeConfig(slots: [0: .apple])
        let plan = service.sacrificeConsumptionPlan(config: config)

        #expect(plan[0] == nil)
    }

    @Test
    func sacrificeConsumptionPlan_sameItemMultipleSlots_insufficientStock_laterSlotsNil() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 2)

        let config = SacrificeConfig(slots: [
            0: .apple,
            1: .apple,
            2: .apple,
        ])
        let plan = service.sacrificeConsumptionPlan(config: config)

        #expect(plan[0] == .apple)
        #expect(plan[1] == .apple)
        #expect(plan[2] == nil)
    }

    @Test
    func sacrificeConsumptionPlan_sameItemMultipleSlots_sufficientStock_allFilled() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .gear, count: 3)

        let config = SacrificeConfig(slots: [
            0: .gear,
            1: .gear,
            2: .gear,
        ])
        let plan = service.sacrificeConsumptionPlan(config: config)

        #expect(plan[0] == .gear)
        #expect(plan[1] == .gear)
        #expect(plan[2] == .gear)
    }

    @Test
    func sacrificeConsumptionPlan_mixedItems_respectsPerItemQuantities() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 1)
        warehouseService.add(item: .rock, count: 1)

        let config = SacrificeConfig(slots: [
            0: .apple,
            1: .rock,
            2: .apple, // second apple — none left
        ])
        let plan = service.sacrificeConsumptionPlan(config: config)

        #expect(plan[0] == .apple)
        #expect(plan[1] == .rock)
        #expect(plan[2] == nil)
    }

    @Test
    func sacrificeConsumptionPlan_isNonMutating_warehouseUnchanged() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let mainStore = assembly.resolver.mainStore()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .copperFlorin, count: 5)

        let before = mainStore.warehouse.quantity(.copperFlorin)
        let config = SacrificeConfig(slots: [0: .copperFlorin, 1: .copperFlorin])
        _ = service.sacrificeConsumptionPlan(config: config)
        let after = mainStore.warehouse.quantity(.copperFlorin)

        #expect(before == after)
        #expect(after == 5)
    }
}
