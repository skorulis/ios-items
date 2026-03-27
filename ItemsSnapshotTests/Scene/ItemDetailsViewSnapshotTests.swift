// Snapshot tests for ItemDetailsView.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct ItemDetailsViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func itemDetails_junk_item() {
        let viewModel = assembler.resolver.itemDetailsViewModel(item: .apple)
        let view = ItemDetailsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func itemDetails_rare_item() {
        assembler.resolver.mainStore().portalUpgrades.purchased.formUnion([.portalUnlocked, .researchLab])
        let viewModel = assembler.resolver.itemDetailsViewModel(item: .astralGem)
        let view = ItemDetailsView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
