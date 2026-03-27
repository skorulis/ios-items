// Created by Cursor on 27/3/2026.
//
// Snapshot tests for AchievementsView.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct AchievementsViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func achievements_default() {
        let viewModel = assembler.resolver.achievementsViewModel()
        let view = AchievementsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
