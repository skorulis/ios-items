// Created by Cursor on 5/3/2026.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct PortalUpgradesViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func portalUpgrades_purchase_segment_empty_warehouse() {
        let viewModel = assembler.resolver.portalUpgradesViewModel()
        let view = PortalUpgradesView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func portalUpgrades_purchase_segment_some_affordable() {
        let mainStore = assembler.resolver.mainStore()
        mainStore.warehouse.add(item: .gear, count: 50)
        mainStore.warehouse.add(item: .copperFlorin, count: 50)

        let viewModel = assembler.resolver.portalUpgradesViewModel()
        let view = PortalUpgradesView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func portalUpgrades_purchased_segment() {
        let mainStore = assembler.resolver.mainStore()
        mainStore.portalUpgrades = PortalUpgrades(purchased: [.portalAutomation, .researchLab])

        let viewModel = assembler.resolver.portalUpgradesViewModel()
        viewModel.segment = .purchased

        let view = PortalUpgradesView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
