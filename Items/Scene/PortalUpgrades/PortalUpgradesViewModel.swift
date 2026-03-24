// Created by Alexander Skorulis on 5/3/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class PortalUpgradesViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    var warehouse: Warehouse = Warehouse()
    var purchasedUpgrades: PortalUpgrades

    private let mainStore: MainStore
    private let upgradeService: UpgradeService
    private let unlockRequirementService: UnlockRequirementService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        upgradeService: UpgradeService,
        unlockRequirementService: UnlockRequirementService
    ) {
        self.mainStore = mainStore
        self.upgradeService = upgradeService
        self.unlockRequirementService = unlockRequirementService
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
        PortalUpgrade.allCases.filter { upgrade in
            !purchasedUpgrades.purchased.contains(upgrade)
                && upgradeService.isUnlocked(upgrade)
        }
    }

    var purchased: [PortalUpgrade] {
        PortalUpgrade.allCases.filter { purchasedUpgrades.purchased.contains($0) }
    }

    func canPurchase(_ upgrade: PortalUpgrade) -> Bool {
        upgradeService.canPurchase(upgrade)
    }

    func isUnlocked(_ upgrade: PortalUpgrade) -> Bool {
        upgradeService.isUnlocked(upgrade)
    }

    func isRequirementComplete(_ requirement: UnlockRequirement) -> Bool {
        unlockRequirementService.isComplete(requirement: requirement)
    }

    @discardableResult
    func purchase(_ upgrade: PortalUpgrade) -> Bool {
        upgradeService.purchase(upgrade)
    }

    func pop() {
        coordinator?.pop()
    }

    func showUpgradeDetail(_ upgrade: PortalUpgrade) {
        coordinator?.custom(overlay: .card, MainPath.portalUpgradeDetail(upgrade))
    }

    func showUpgradeLongFormExplanation(_ upgrade: PortalUpgrade) {
        coordinator?.custom(overlay: .card, MainPath.fullDialog(upgrade.detailedExplanation))
    }
}
