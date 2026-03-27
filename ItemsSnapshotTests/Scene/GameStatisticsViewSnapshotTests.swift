// Created by Cursor on 27/3/2026.
//
// Snapshot tests for GameStatisticsView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct GameStatisticsViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func gameStatistics_default() {
        let viewModel = assembler.resolver.gameStatisticsViewModel()
        let view = GameStatisticsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
