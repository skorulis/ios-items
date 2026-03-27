// Created by Cursor on 27/3/2026.
//
// Snapshot tests for EquipmentDetailView.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct EquipmentDetailViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func equipmentDetail_default() {
        let instance = EquipmentInstance(kind: .dagger, material: .stone, quality: .junk)
        let viewModel = assembler.resolver.equipmentDetailViewModel(equipment: instance)
        let view = EquipmentDetailView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
