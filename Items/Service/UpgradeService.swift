//Created by Alexander Skorulis on 5/3/2026.

import ASKCore
import Combine
import Foundation
import Knit
import KnitMacros

final class UpgradeService: ObservableObject {

    private let mainStore: MainStore
    private let achievementService: AchievementService
    private var cancellables: Set<AnyCancellable> = []

    @Published var purchasableUpgrades: [PortalUpgrade] = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, achievementService: AchievementService) {
        self.mainStore = mainStore
        self.achievementService = achievementService

        mainStore.$portalUpgrades
            .combineLatest(mainStore.$achievements)
            .combineLatest(mainStore.$warehouse)
            .delayedChange()
            .sink { [unowned self] _ in self.updatePurchasableUpgrades() }
            .store(in: &cancellables)
        
    }
}

// MARK: - Queries

extension UpgradeService {

    /// Number of upgrades that are not yet purchased and can be afforded with the current warehouse.
    private func updatePurchasableUpgrades() {
        let purchased = mainStore.portalUpgrades.purchased
        let newValue = PortalUpgrade.allCases.filter { upgrade in
            !purchased.contains(upgrade)
                && isUnlocked(upgrade)
                && canPurchase(upgrade)
        }
        
        if newValue != purchasableUpgrades {
            purchasableUpgrades = newValue
        }
    }

    func canPurchase(_ upgrade: PortalUpgrade) -> Bool {
        guard isUnlocked(upgrade) else { return false }
        return upgrade.cost.allSatisfy { mainStore.warehouse.quantity($0.item) >= $0.quantity }
    }
}

// MARK: - Mutations

extension UpgradeService {

    /// Deducts the upgrade's cost from the warehouse and adds the upgrade to purchased. No-op if not affordable.
    func purchase(_ upgrade: PortalUpgrade) {
        guard canPurchase(upgrade) else { return }
        for costItem in upgrade.cost {
            mainStore.warehouse.remove(item: costItem.item, quantity: costItem.quantity)
        }
        mainStore.portalUpgrades.purchased.insert(upgrade)
    }

    /// Whether the given upgrade's unlock requirement (if any) has been satisfied.
    func isUnlocked(_ upgrade: PortalUpgrade) -> Bool {
        guard let requirement = upgrade.requirement else { return true }
        return achievementService.isComplete(requirement: requirement)
    }

}
