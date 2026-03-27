// Created by Cursor on 27/3/2026.
//
// Snapshot tests for EncyclopediaView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct EncyclopediaViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func encyclopedia_root() {
        let viewModel = assembler.resolver.encyclopediaViewModel(entry: .root)
        let view = EncyclopediaView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
