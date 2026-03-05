//Created by Alexander Skorulis on 5/3/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class PortalUpgradesViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?

    enum Segment: String, CaseIterable {
        case purchase = "Purchase"
        case purchased = "Purchased"
    }

    var segment: Segment = .purchase
    var warehouse: Warehouse = Warehouse()
    var purchasedUpgrades: PortalUpgrades

    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.warehouse = mainStore.warehouse
        self.purchasedUpgrades = mainStore.portalUpgrades
        mainStore.$warehouse.sink { [weak self] in
            self?.warehouse = $0
        }
        .store(in: &cancellables)
        mainStore.$portalUpgrades.sink { [weak self] in
            self?.purchasedUpgrades = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension PortalUpgradesViewModel {
    var availableToPurchase: [PortalUpgrade] {
        PortalUpgrade.allCases.filter { !purchasedUpgrades.purchased.contains($0) }
    }

    var purchased: [PortalUpgrade] {
        PortalUpgrade.allCases.filter { purchasedUpgrades.purchased.contains($0) }
    }

    func canPurchase(_ upgrade: PortalUpgrade) -> Bool {
        upgrade.cost.allSatisfy { warehouse.quantity($0.item) >= $0.quantity }
    }

    func purchase(_ upgrade: PortalUpgrade) {
        guard canPurchase(upgrade) else { return }
        var w = mainStore.warehouse
        for costItem in upgrade.cost {
            w.remove(item: costItem.item, quantity: costItem.quantity)
        }
        mainStore.warehouse = w
        var up = mainStore.portalUpgrades
        up.purchased.insert(upgrade)
        mainStore.portalUpgrades = up
    }

    func pop() {
        coordinator?.pop()
    }
}
