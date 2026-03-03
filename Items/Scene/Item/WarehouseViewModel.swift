//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Knit
import KnitMacros
import SwiftUI

@Observable final class WarehouseViewModel: CoordinatorViewModel {

    var coordinator: Coordinator?

    private let mainStore: MainStore
    private let warehouseService: WarehouseService
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    var page: Page = .items {
        didSet {
            clearNew()
        }
    }
    var model = WarehouseView.Model()

    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, warehouseService: WarehouseService) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        warehouse = mainStore.warehouse
        lab = mainStore.lab

        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)

        mainStore.$lab.sink { [unowned self] in
            self.lab = $0
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
        model.newItemsToShow = warehouse.newItems
        model.newArtifactsToShow = warehouse.newArtifacts
        
        clearNew()
    }
    
    private func clearNew() {
        switch self.page {
        case .artifacts:
            warehouseService.clearNewArtifacts()
        case .items:
            warehouseService.clearNewItems()
        }
    }

    func isNew(item: BaseItem) -> Bool {
        model.newItemsToShow.contains(item)
    }

    func isNew(artifact: Artifact) -> Bool {
        model.newArtifactsToShow.contains(artifact)
    }

    func showInfo() {
        coordinator?.custom(overlay: .card, MainPath.dialog(HelpStrings.warehouse))
    }

    func pressed(artifact: ArtifactInstance) {
        model.newArtifactsToShow.remove(artifact.type)
        coordinator?.custom(overlay: .card, MainPath.artifactDetails(artifact))
    }

    func pressed(item: BaseItem) {
        model.newItemsToShow.remove(item)
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }
}
