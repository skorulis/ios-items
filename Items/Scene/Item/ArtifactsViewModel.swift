// Created by Alexander Skorulis on 11/2/2026.
//
// Split out artifacts logic from `WarehouseViewModel`.

import ASKCoordinator
import Combine
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable
final class ArtifactsViewModel {
    
    weak var coordinator: ASKCoordinator.Coordinator?
    
    struct Model {
        var newArtifactsToShow: Set<Artifact> = []
        var maxArtifactSlots: Int = 0
    }

    private let mainStore: MainStore
    private let warehouseService: WarehouseService
    private let calculationService: CalculationsService

    private(set) var warehouse: Warehouse

    var model = Model()

    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        warehouseService: WarehouseService,
        calculationService: CalculationsService,
    ) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        self.calculationService = calculationService
        self.warehouse = mainStore.warehouse

        mainStore.$warehouse
            .sink { [weak self] in self?.warehouse = $0 }
            .store(in: &cancellables)

        calculationService.$maxArtifactSlots
            .sink { [weak self] in self?.model.maxArtifactSlots = $0 }
            .store(in: &cancellables)
    }
}

// MARK: - Public API (owned by ArtifactsView)

extension ArtifactsViewModel {
    func onAppear() {
        // Snapshot "new" state for badges, then let the screen decide when
        // to clear persisted flags.
        model.newArtifactsToShow = mainStore.notifications.newArtifacts
    }

    func clearNewArtifacts() {
        warehouseService.clearNewArtifacts()
    }

    func isNew(artifact: Artifact) -> Bool {
        model.newArtifactsToShow.contains(artifact)
    }

    func showArtifactBonusesInfo() {
        let bonuses = warehouse.artifactBonuses
        guard !bonuses.isEmpty else {
            coordinator?.custom(
                overlay: .card,
                MainPath.dialog("No artifact bonuses are currently active. Equip artifacts to gain bonuses.")
            )
            return
        }

        let header = "Current artifact bonuses:\n"
        let list = bonuses.map { "• \($0.text)" }.joined(separator: "\n")
        coordinator?.custom(overlay: .card, MainPath.dialog(header + list))
    }

    func artifactSlotPresed(index: Int) {
        coordinator?.custom(overlay: .card, MainPath.artifactPicker(slot: index))
    }

    func pressed(artifact: ArtifactInstance) {
        model.newArtifactsToShow.remove(artifact.type)
        coordinator?.custom(overlay: .card, MainPath.artifactDetails(artifact))
    }
}
