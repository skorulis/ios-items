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
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    var artifactsViewModel: ArtifactsViewModel

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
    ) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        warehouse = mainStore.warehouse
        lab = mainStore.lab
        self.artifactsViewModel = artifactsViewModel

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
    }
}

// MARK: - Inner Types

extension WarehouseViewModel {
    enum Page {
        case items, artifacts
    }
}

// MARK: - Logic

extension WarehouseViewModel {

    func onAppear() {
        // Capture current "new" state for the UI, but immediately clear persisted flags
        model.newItemsToShow = mainStore.notifications.newItems
        artifactsViewModel.onAppear()

        clearNew()
    }

    private func clearNew() {
        switch self.page {
        case .artifacts:
            artifactsViewModel.clearNewArtifacts()
        case .items:
            warehouseService.clearNewItems()
        }
    }

    func isNew(item: BaseItem) -> Bool {
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

    func pressed(item: BaseItem) {
        model.newItemsToShow.remove(item)
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }
}
