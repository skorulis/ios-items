// Created by Cursor on 12/3/2026.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct SacrificeViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    private func setSacrificeConfig(_ config: SacrificeConfig) {
        let mainStore = assembler.resolver.mainStore()
        var recipes = mainStore.recipes
        recipes.sacrificeConfig = config
        mainStore.recipes = recipes
    }

    @Test
    func sacrificeView_empty_slots() {
        setSacrificeConfig(SacrificeConfig(slots: [:]))
        let viewModel = assembler.resolver.sacrificeViewModel()
        let view = SacrificeView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeView_slots_configured_no_stock_gray_borders() {
        // Configured items but warehouse empty → plan unsatisfied → gray circles
        setSacrificeConfig(SacrificeConfig(slots: [0: .apple, 2: .gear]))
        let viewModel = assembler.resolver.sacrificeViewModel()
        let view = SacrificeView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeView_slots_with_stock_green_borders() {
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
