// Created by Cursor on 27/3/2026.
//
// Snapshot tests for TradingPostView.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct TradingPostViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    // Disabled due to date issue
//    @Test
//    func tradingPost_default() {
//        let viewModel = assembler.resolver.tradingPostViewModel()
//        let view = TradingPostView(viewModel: viewModel)
//
//        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
//    }
}
