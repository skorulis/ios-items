// Created by Cursor on 27/3/2026.
//
// Snapshot tests for EssenceBreakdownView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct EssenceBreakdownViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func essenceBreakdown_default() {
        let viewModel = assembler.resolver.essenceBreakdownViewModel()
        let view = EssenceBreakdownView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
