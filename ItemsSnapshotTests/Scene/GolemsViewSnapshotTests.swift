// Created by Alexander Skorulis on 23/3/2026.
//
// Snapshot tests for GolemsView.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct GolemsViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func golems_construction_initial_empty() {
        let viewModel = assembler.resolver.golemsViewModel()
        let view = GolemsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func golems_construction_stocked_warehouse_and_owned() {
        let mainStore = assembler.resolver.mainStore()

        mainStore.warehouse.add(item: .rock, count: 50)
        mainStore.warehouse.add(item: .gear, count: 50)
        mainStore.warehouse.add(item: .copperFlorin, count: 50)
        mainStore.warehouse.add(item: .metalBloom, count: 50)
        mainStore.warehouse.add(item: .silverFlorin, count: 50)
        mainStore.warehouse.add(item: .quartzCrystal, count: 50)
        mainStore.warehouse.add(item: .lens, count: 50)
        mainStore.warehouse.add(item: .goldFlorin, count: 50)

        var golems = mainStore.golems
        golems.inventory[.clay] = 2
        golems.inventory[.iron] = 1
        mainStore.golems = golems

        let viewModel = assembler.resolver.golemsViewModel()
        let view = GolemsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func golems_missions_setup_empty() {
        let viewModel = assembler.resolver.golemsViewModel()
        viewModel.segment = .missions
        let view = GolemsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func golems_missions_setup_ready_to_start() {
        let mainStore = assembler.resolver.mainStore()

        var golems = mainStore.golems
        golems.slots[0] = GolemMissionSlot(
            phase: .setup,
            golemType: .clay,
            location: .vesprium,
            remainingHealth: nil
        )
        mainStore.golems = golems

        let viewModel = assembler.resolver.golemsViewModel()
        viewModel.segment = .missions
        let view = GolemsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
