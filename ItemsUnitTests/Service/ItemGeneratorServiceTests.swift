//Created by Alexander Skorulis on 11/3/2026.

@testable import Items
import Foundation
import Knit
import Models
import Testing

@MainActor
struct ItemGeneratorServiceTests {

    private func setSacrificeConfig(_ assembly: ScopedModuleAssembler<BaseResolver>, config: SacrificeConfig) {
        let mainStore = assembly.resolver.mainStore()
        var recipes = mainStore.recipes
        recipes.sacrificeConfig = config
        mainStore.recipes = recipes
    }

    // MARK: - sacrificeConsumptionPlan

    @Test
    func sacrificeConsumptionPlan_emptyConfig_allSlotsNil() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [:]))

        let plan = service.sacrificeConsumptionPlan()

        for index in 0..<SacrificeConfig.slotCount {
            #expect(plan.item(at: index) == nil)
        }
    }

    @Test
    func sacrificeConsumptionPlan_singleSlot_withStock_returnsItem() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 1)
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [0: .apple]))

        let plan = service.sacrificeConsumptionPlan()

        #expect(plan.item(at: 0) == .apple)
        for index in 1..<SacrificeConfig.slotCount {
            #expect(plan.item(at: index) == nil)
        }
    }

    @Test
    func sacrificeConsumptionPlan_singleSlot_withoutStock_returnsNil() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [0: .apple]))

        let plan = service.sacrificeConsumptionPlan()

        #expect(plan.item(at: 0) == nil)
    }

    @Test
    func sacrificeConsumptionPlan_sameItemMultipleSlots_insufficientStock_laterSlotsNil() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 2)
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [
            0: .apple,
            1: .apple,
            2: .apple,
        ]))

        let plan = service.sacrificeConsumptionPlan()

        #expect(plan.item(at: 0) == .apple)
        #expect(plan.item(at: 1) == .apple)
        #expect(plan.item(at: 2) == nil)
    }

    @Test
    func sacrificeConsumptionPlan_sameItemMultipleSlots_sufficientStock_allFilled() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .gear, count: 3)
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [
            0: .gear,
            1: .gear,
            2: .gear,
        ]))

        let plan = service.sacrificeConsumptionPlan()

        #expect(plan.item(at: 0) == .gear)
        #expect(plan.item(at: 1) == .gear)
        #expect(plan.item(at: 2) == .gear)
    }

    @Test
    func sacrificeConsumptionPlan_mixedItems_respectsPerItemQuantities() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 1)
        warehouseService.add(item: .rock, count: 1)
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [
            0: .apple,
            1: .rock,
            2: .apple,
        ]))

        let plan = service.sacrificeConsumptionPlan()

        #expect(plan.item(at: 0) == .apple)
        #expect(plan.item(at: 1) == .rock)
        #expect(plan.item(at: 2) == nil)
    }

    @Test
    func sacrificeConsumptionPlan_isNonMutating_warehouseUnchanged() {
        let assembly = ItemsAssembly.testing()
        let service = assembly.resolver.itemGeneratorService()
        let mainStore = assembly.resolver.mainStore()
        let warehouseService = assembly.resolver.warehouseService()
        warehouseService.add(item: .copperFlorin, count: 5)
        setSacrificeConfig(assembly, config: SacrificeConfig(slots: [0: .copperFlorin, 1: .copperFlorin]))

        let before = mainStore.warehouse.quantity(.copperFlorin)
        _ = service.sacrificeConsumptionPlan()
        let after = mainStore.warehouse.quantity(.copperFlorin)

        #expect(before == after)
        #expect(after == 5)
    }
}
