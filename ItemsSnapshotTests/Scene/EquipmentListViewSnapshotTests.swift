// Created by Cursor on 27/3/2026.
//
// Snapshot tests for EquipmentListView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct EquipmentListViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func equipmentList_default() {
        let viewModel = assembler.resolver.equipmentListViewModel()
        let view = EquipmentListView(
            viewModel: viewModel,
            contentOnly: false,
        )

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
