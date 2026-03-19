// Created by Cursor on 16/3/2026.
//
// View model for selecting and unlocking map locations.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class MapLocationViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    /// Snapshot of the player's warehouse used to show item quantities.
    var warehouse: Warehouse = Warehouse()

    /// Snapshot of the current map location state.
    var mapLocations: MapLocations

    var segment: MapLocationView.Segment = .purchased

    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.mapLocations = mainStore.mapLocations
        self.warehouse = mainStore.warehouse

        mainStore.$mapLocations
            .sink { [weak self] in self?.mapLocations = $0 }
            .store(in: &cancellables)

        mainStore.$warehouse
            .sink { [weak self] in self?.warehouse = $0 }
            .store(in: &cancellables)
    }
}

// MARK: - Logic

extension MapLocationViewModel {

    /// All locations that can appear in the UI.
    var allLocations: [MapLocation] {
        Array(MapLocation.allCases)
    }

    func isUnlocked(_ location: MapLocation) -> Bool {
        mapLocations.isUnlocked(location)
    }

    func isSelected(_ location: MapLocation) -> Bool {
        mapLocations.selected == location
    }

    func canAfford(_ location: MapLocation) -> Bool {
        location.details.cost.allSatisfy { line in
            warehouse.quantity(line.item) >= line.quantity
        }
    }

    func purchase(_ location: MapLocation) {
        guard !isUnlocked(location), canAfford(location) else { return }

        // Spend items from warehouse.
        for line in location.details.cost {
            mainStore.warehouse.remove(item: line.item, quantity: line.quantity)
        }

        // Unlock the location (and keep selection unchanged).
        mainStore.mapLocations.unlocked.insert(location)
    }

    func select(_ location: MapLocation) {
        guard isUnlocked(location) else { return }
        mainStore.mapLocations.selected = location
    }

    func showBonuses(for location: MapLocation) {
        coordinator?.custom(overlay: .card, MainPath.mapLocationBonuses(location))
    }

    func pop() {
        coordinator?.pop()
    }
}
