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
    func golems_with_startable_mission_slots() {
        let mainStore = assembler.resolver.mainStore()

        mainStore.portalUpgrades.purchased.formUnion([.golems, .golemMissionSlotsLevel2])
        mainStore.warehouse.add(item: .portalShard, count: 3)

        let viewModel = assembler.resolver.golemsViewModel()
        let view = GolemsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
