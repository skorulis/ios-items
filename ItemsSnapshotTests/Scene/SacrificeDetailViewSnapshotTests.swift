// Created by Cursor on 4/3/2026.

@testable import Items
import Models
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct SacrificeDetailViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func sacrificeDetail_simple() {
        let mainStore = assembler.resolver.mainStore()
        mainStore.sacrifices.sacrificeConfig = .init(
            slots: [0: .apple],
        )
        mainStore.warehouse.add(item: .apple)
        mainStore.lab.set(level: 5, item: .apple)

        let viewModel = assembler.resolver.currentSacrificeDetailViewModel()
        let view = SacrificeDetailView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeDetail_complex() {
        let mainStore = assembler.resolver.mainStore()

        mainStore.sacrifices.sacrificeConfig = .init(
            slots: [0: .apple, 1: .gear, 2: .copperFlorin, 3: .silverFlorin],
        )

        mainStore.warehouse.add(item: .apple)
        mainStore.warehouse.add(item: .gear)
        mainStore.warehouse.add(item: .copperFlorin)
        mainStore.warehouse.add(item: .silverFlorin)

        mainStore.lab.set(level: 5, item: .apple)
        mainStore.lab.set(level: 5, item: .gear)
        mainStore.lab.set(level: 5, item: .copperFlorin)
        mainStore.lab.set(level: 5, item: .silverFlorin)

        let viewModel = assembler.resolver.currentSacrificeDetailViewModel()
        let view = SacrificeDetailView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func sacrificeDetail_location_blocks_some_essences() {
        let mainStore = assembler.resolver.mainStore()

        // Configure sacrifices that would normally produce a mix of essences.
        mainStore.sacrifices.sacrificeConfig = .init(
            slots: [0: .apple, 1: .gear, 2: .copperFlorin],
        )
        mainStore.warehouse.add(item: .apple)
        mainStore.warehouse.add(item: .gear)
        mainStore.warehouse.add(item: .copperFlorin)

        // Give all items some research level to unlock essences.
        mainStore.lab.set(level: 5, item: .apple)
        mainStore.lab.set(level: 5, item: .gear)
        mainStore.lab.set(level: 5, item: .copperFlorin)

        // Choose a location that zeroes out some essences (e.g. dark and earth at Semil Trading Post).
        mainStore.mapLocations.selected = .semilTradingPost

        let viewModel = assembler.resolver.currentSacrificeDetailViewModel()
        let view = SacrificeDetailView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
