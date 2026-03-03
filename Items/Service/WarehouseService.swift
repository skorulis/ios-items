//Created by Alexander Skorulis on 3/3/2026.

import Foundation
import Knit
import KnitMacros

/// Service responsible for all mutations to `MainStore.warehouse`.
/// This ensures that changes always go through `MainStore` so persistence
/// and observers are correctly updated.
final class WarehouseService {

    private let mainStore: MainStore
    private let toastService: ToastService

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, toastService: ToastService) {
        self.mainStore = mainStore
        self.toastService = toastService
    }
}

// MARK: - Public API

extension WarehouseService {

    /// Add items to the warehouse.
    func add(item: BaseItem, count: Int = 1) {
        if !mainStore.warehouse.hasDiscovered(item) {
            toastService.showToast("Discovered \(item.name)")
        }
        mainStore.warehouse.add(item: item, count: count)
    }

    /// Remove items from the warehouse.
    func remove(item: BaseItem, quantity: Int = 1) {
        mainStore.warehouse.remove(item: item, quantity: quantity)
    }

    /// Add / upgrade an artifact in the warehouse.
    func add(artifact: ArtifactInstance) {
        if mainStore.warehouse.isNewDiscovery(artifact: artifact) {
            if artifact.quality == .junk {
                toastService.showToast("Discovered \(artifact.type.name)")
            } else {
                toastService.showToast("Upgraded \(artifact.type.name)")
            }
        }
        mainStore.warehouse.add(artifact: artifact)
    }

    /// Mark an item as viewed so it no longer appears as new.
    func markItemViewed(_ item: BaseItem) {
        mainStore.warehouse.markViewed(item: item)
    }

    /// Mark an artifact as viewed so it no longer appears as new.
    func markArtifactViewed(_ artifact: Artifact) {
        mainStore.warehouse.markViewed(artifact: artifact)
    }

    /// Clear all "new" flags for items.
    func clearNewItems() {
        mainStore.warehouse.newItems.removeAll()
    }

    /// Clear all "new" flags for artifacts.
    func clearNewArtifacts() {
        mainStore.warehouse.newArtifacts.removeAll()
    }

    /// Clear all "new" discovery flags.
    func clearNewDiscoveries() {
        mainStore.warehouse.clearNewDiscoveries()
    }

    /// Equip an artifact in the warehouse.
    func equip(_ artifact: Artifact) {
        mainStore.warehouse.equip(artifact)
    }

    /// Unequip an artifact in the warehouse.
    func unequip(_ artifact: Artifact) {
        mainStore.warehouse.unequip(artifact)
    }
}

