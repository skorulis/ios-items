// Created by Cursor on 16/3/2026.
//
// Snapshot tests for MapLocationView.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct MapLocationViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func mapLocations_initial_state() {
        let viewModel = assembler.resolver.mapLocationViewModel()
        let view = MapLocationView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func mapLocations_initial_state_available() {
        let viewModel = assembler.resolver.mapLocationViewModel()
        viewModel.segment = .available
        let view = MapLocationView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func mapLocations_some_unlocked_and_selected() {
        let mainStore = assembler.resolver.mainStore()

        // Unlock a couple of locations and select one.
        mainStore.mapLocations.unlocked = [.vesprium, .semilTradingPost]
        mainStore.mapLocations.selected = .semilTradingPost

        // Give the player enough resources to unlock at least one location.
        mainStore.warehouse.add(item: .mapFragment, count: 5)
        mainStore.warehouse.add(item: .silverFlorin, count: 5)

        let viewModel = assembler.resolver.mapLocationViewModel()
        let view = MapLocationView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
