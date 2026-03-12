//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

@Observable final class DebugViewModel {

    let mainStore: MainStore
    let warehouseService: WarehouseService
    private let toastService: ToastService
    let debugConnectionService: DebugConnectionService

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, warehouseService: WarehouseService, toastService: ToastService, debugConnectionService: DebugConnectionService) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        self.toastService = toastService
        self.debugConnectionService = debugConnectionService
    }
}

// MARK: - Logic

extension DebugViewModel {

    func resetUpgrades() {
        mainStore.portalUpgrades = PortalUpgrades()
    }

    // MARK: - MainStore resets (debug)

    func resetWarehouse() {
        mainStore.warehouse = Warehouse()
    }

    func resetStatistics() {
        mainStore.statistics = Statistics()
    }

    func resetRecipes() {
        mainStore.recipes = Recipes()
    }

    func resetLab() {
        mainStore.lab = Laboratory()
    }

    func resetAchievements() {
        mainStore.achievements = Achievements()
    }

    func resetConcepts() {
        mainStore.concepts = Concepts()
    }

    func resetNotifications() {
        mainStore.notifications = Notifications()
    }

    /// Resets every persisted slice of `MainStore` to its initial empty state.
    func resetAllMainStore() {
        resetWarehouse()
        resetStatistics()
        resetRecipes()
        resetLab()
        resetAchievements()
        resetUpgrades()
        resetConcepts()
        resetNotifications()
    }
    
    func addItems() {
        for item in BaseItem.allCases {
            mainStore.warehouse.add(item: item, count: 1)
        }
    }
    
    func addArtifacts() {
        for artifact in Artifact.allCases {
            if let existing = mainStore.warehouse.artifactInstance(artifact),
               let next = existing.quality.next {
                warehouseService.add(artifact: .init(type: artifact, quality: next))
            } else {
                warehouseService.add(artifact: .init(type: artifact, quality: .junk))
            }
        }
    }

    func showTestToast() {
        toastService.showToast("Debug toast • \(UUID().uuidString)")
    }
}

