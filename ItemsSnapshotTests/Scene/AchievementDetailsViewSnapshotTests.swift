// Created by Cursor on 27/3/2026.
//
// Snapshot tests for AchievementDetailsView.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct AchievementDetailsViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func achievementDetails_default() {
        let viewModel = assembler.resolver.achievementDetailsViewModel(achievement: .items10)
        let view = AchievementDetailsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
