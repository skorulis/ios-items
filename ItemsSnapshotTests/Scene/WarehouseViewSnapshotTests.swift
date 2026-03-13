// Created by Cursor on 3/3/2026.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct WarehouseViewSnapshotTests {

    @Test
    func warehouse_empty_items() {
        let assembler = ItemsAssembly.testing()
        let viewModel = assembler.resolver.warehouseViewModel()
        let view = WarehouseView(viewModel: viewModel)
        
        let mainStore = assembler.resolver.mainStore()
        mainStore.warehouse.add(item: .apple, count: 1)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func warehouse_with_items() {
        let assembler = ItemsAssembly.testing()
        let mainStore = assembler.resolver.mainStore()

        mainStore.warehouse.add(item: .apple, count: 5)
        mainStore.warehouse.add(item: .silverFlorin, count: 3)
        mainStore.warehouse.add(item: .goldFlorin, count: 1)

        let viewModel = assembler.resolver.warehouseViewModel()
        let view = WarehouseView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func warehouse_artifacts_tab_with_equipped() {
        let assembler = ItemsAssembly.testing()
        let mainStore = assembler.resolver.mainStore()

        // Unlock artifacts tab.
        mainStore.achievements.add(achievements: [.artifact1])

        // Add and equip a couple of artifacts.
        mainStore.warehouse.add(artifact: ArtifactInstance(type: .frictionlessGear, quality: .good))
        mainStore.warehouse.add(artifact: ArtifactInstance(type: .luckyCoin, quality: .common))
        mainStore.warehouse.equip(.frictionlessGear, slot: 0)
        mainStore.warehouse.equip(.luckyCoin, slot: 1)

        let viewModel = assembler.resolver.warehouseViewModel()
        viewModel.page = .artifacts

        let view = WarehouseView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}

