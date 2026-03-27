// Created by Cursor on 27/3/2026.
//
// Snapshot tests for ArtifactsContainerView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct ArtifactsContainerViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func artifactsContainer_default() {
        let viewModel = assembler.resolver.artifactsViewModel()
        let view = ArtifactsContainerView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
