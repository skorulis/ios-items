// Created by Cursor on 12/3/2026.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct SacrificeViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    private func setSacrificeConfig(_ config: SacrificeConfig) {
        let mainStore = assembler.resolver.mainStore()
        var recipes = mainStore.recipes
        recipes.sacrificeConfig = config
        mainStore.recipes = recipes
    }

    /// Unlocks all pentagram slots in the UI (matches four sacrifice-slot upgrades after base sacrifices).
    private func unlockAllSacrificeSlots() {
        let mainStore = assembler.resolver.mainStore()
        var pu = mainStore.portalUpgrades
        pu.purchased.formUnion([
            .sacrifices,
            .sacrificesLevel2,
            .sacrificesLevel3,
            .sacrificesLevel4,
            .sacrificesLevel5,
        ])
        mainStore.portalUpgrades = pu
    }

    @Test
    func sacrificeView_empty_slots() {
        unlockAllSacrificeSlots()
        setSacrificeConfig(SacrificeConfig(slots: [:]))
        let viewModel = assembler.resolver.sacrificeViewModel()
        let view = SacrificeView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeView_slots_configured_no_stock_gray_borders() {
        unlockAllSacrificeSlots()
        // Configured items but warehouse empty → plan unsatisfied → gray circles
        setSacrificeConfig(SacrificeConfig(slots: [0: .apple, 2: .gear]))
        let viewModel = assembler.resolver.sacrificeViewModel()
        let view = SacrificeView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeView_slots_with_stock_green_borders() {
        unlockAllSacrificeSlots()
        let warehouseService = assembler.resolver.warehouseService()
        warehouseService.add(item: .apple, count: 2)
        warehouseService.add(item: .gear, count: 1)
        setSacrificeConfig(SacrificeConfig(slots: [0: .apple, 1: .apple, 3: .gear]))
        let viewModel = assembler.resolver.sacrificeViewModel()
        let view = SacrificeView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeView_sacrifices_disabled() {
        unlockAllSacrificeSlots()
        let mainStore = assembler.resolver.mainStore()
        var recipes = mainStore.recipes
        recipes.sacrificesEnabled = false
        recipes.sacrificeConfig = SacrificeConfig(slots: [0: .apple])
        mainStore.recipes = recipes
        assembler.resolver.warehouseService().add(item: .apple, count: 1)

        let viewModel = assembler.resolver.sacrificeViewModel()
        let view = SacrificeView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
