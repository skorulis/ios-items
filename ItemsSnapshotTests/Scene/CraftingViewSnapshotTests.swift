// Created by Cursor on 27/3/2026.
//
// Snapshot tests for CraftingView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct CraftingViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func crafting_default() {
        let viewModel = assembler.resolver.craftingViewModel()
        let view = CraftingView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
