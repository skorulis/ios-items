// Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class WarehouseViewModel: CoordinatorViewModel {

    weak var coordinator: ASKCoordinator.Coordinator? {
        didSet {
            artifactsViewModel.coordinator = coordinator
        }
    }

    private let mainStore: MainStore
    private let warehouseService: WarehouseService
    private let analytics: AnalyticsService
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    var artifactsViewModel: ArtifactsViewModel
    var equipmentListViewModel: EquipmentListViewModel

    var page: Page = .items {
        didSet {
            clearNew()
        }
    }
    var model = WarehouseView.Model()

    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        warehouseService: WarehouseService,
        calculationService: CalculationsService,
        artifactsViewModel: ArtifactsViewModel,
        equipmentListViewModel: EquipmentListViewModel,
        analytics: AnalyticsService,
    ) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        self.analytics = analytics
        warehouse = mainStore.warehouse
        lab = mainStore.lab
        self.artifactsViewModel = artifactsViewModel
        self.equipmentListViewModel = equipmentListViewModel
        self.model.showTradingPostButton = mainStore.portalUpgrades.purchased.contains(.tradingPost)

        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)

        mainStore.$lab.sink { [unowned self] in
            self.lab = $0
        }
        .store(in: &cancellables)

        mainStore.$achievements.sink { [unowned self]  in
            self.model.showArtifactsTab = $0.unlocked.contains(.artifact1)
        }
        .store(in: &cancellables)

        mainStore.$portalUpgrades.sink { [unowned self] in
            self.model.showTradingPostButton = $0.purchased.contains(.tradingPost)
        }
        .store(in: &cancellables)
    }
}

// MARK: - Inner Types

extension WarehouseViewModel {
    enum Page {
        case items, artifacts, equipment
    }
}

// MARK: - Logic

extension WarehouseViewModel {

    func onAppear() {
        analytics.viewScreen(name: "warehouse")
        // Capture current "new" state for the UI, but immediately clear persisted flags
        model.newItemsToShow = mainStore.notifications.newItems
        artifactsViewModel.onAppear()

        // If a segment becomes unavailable, fall back to ingredients.
        if page == .artifacts && !model.showArtifactsTab {
            page = .items
        }
        if page == .equipment && !hasEquipment {
            page = .items
        }

        clearNew()
    }

    private func clearNew() {
        switch self.page {
        case .artifacts:
            artifactsViewModel.clearNewArtifacts()
        case .items:
            warehouseService.clearNewItems()
        case .equipment:
            break
        }
    }

    func isNew(item: Ingredient) -> Bool {
        model.newItemsToShow.contains(item)
    }

    func showInfo() {
        coordinator?.custom(
            overlay: .card,
            MainPath.fullDialog(.init(bodyText: HelpStrings.warehouse, title: "Warehouse"))
        )
    }

    func showEssenceBreakdown() {
        coordinator?.push(MainPath.essenceBreakdown)
    }

    func showTradingPost() {
        coordinator?.push(MainPath.tradingPost)
    }

    var hasDiscoveredRecipes: Bool {
        !warehouse.recipes.isEmpty
    }

    func showCrafting() {
        coordinator?.push(MainPath.crafting)
    }

    var hasEquipment: Bool {
        !warehouse.equipment.isEmpty || warehouse.equipmentUnlocked
    }

    func showEquipmentList() {
        coordinator?.push(MainPath.equipmentList)
    }

    func pressed(item: Ingredient) {
        model.newItemsToShow.remove(item)
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }
}
