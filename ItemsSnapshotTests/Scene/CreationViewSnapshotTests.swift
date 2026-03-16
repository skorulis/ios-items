// Created by Alexander Skorulis on 03/3/2026.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct CreationViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func creationView_default() {
        let viewModel = assembler.resolver.creationViewModel()
        let view = CreationView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func creationView_withUpgradesProgressTowardsUnlock() {
        assembler.resolver.warehouseService().add(item: .apple)
        assembler.resolver.mainStore().statistics.itemsCreated = 2
        assembler.resolver.mainStore().achievements.unlocked.insert(.items1)
        let viewModel = assembler.resolver.creationViewModel()
        let view = CreationView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
