//Created by Alexander Skorulis on 3/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

/// Service responsible for all mutations to `MainStore.warehouse`.
/// This ensures that changes always go through `MainStore` so persistence
/// and observers are correctly updated.
final class WarehouseService {

    private let mainStore: MainStore
    private let toastService: ToastService
    private let calculationService: CalculationsService
    private let achievementService: AchievementService
    private let researchService: ResearchService

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        toastService: ToastService,
        calculationService: CalculationsService,
        achievementService: AchievementService,
        researchService: ResearchService
    ) {
        self.mainStore = mainStore
        self.toastService = toastService
        self.calculationService = calculationService
        self.achievementService = achievementService
        self.researchService = researchService
    }
}

// MARK: - Public API

extension WarehouseService {

    /// Add items to the warehouse.
    func add(item: BaseItem, count: Int = 1) {
        let wasNewDiscovery = !mainStore.warehouse.hasDiscovered(item)
        mainStore.warehouse.add(item: item, count: count)
        if wasNewDiscovery {
            toastService.showToast("Discovered \(item.name)")
            mainStore.notifications.recordNewItemDiscovery(item)
        }
    }

    /// Remove items from the warehouse.
    func remove(item: BaseItem, quantity: Int = 1) {
        mainStore.warehouse.remove(item: item, quantity: quantity)
    }

    /// Add / upgrade an artifact in the warehouse.
    func add(artifact: ArtifactInstance) {
        let wasNewDiscovery = mainStore.warehouse.isNewDiscovery(artifact: artifact)
        mainStore.warehouse.add(artifact: artifact)
        if wasNewDiscovery {
            if artifact.quality == .junk {
                toastService.showToast("Discovered \(artifact.type.name)")
            } else {
                toastService.showToast("Upgraded \(artifact.type.name)")
            }
            mainStore.notifications.recordNewArtifactDiscovery(artifact.type)
        }
    }

    /// Mark an item as viewed so it no longer appears as new.
    func markItemViewed(_ item: BaseItem) {
        mainStore.notifications.markItemViewed(item)
    }

    /// Mark an artifact as viewed so it no longer appears as new.
    func markArtifactViewed(_ artifact: Artifact) {
        mainStore.notifications.markArtifactViewed(artifact)
    }

    func clearNewItems() {
        if !mainStore.notifications.newItems.isEmpty {
            mainStore.notifications.newItems.removeAll()
        }
    }

    func clearNewArtifacts() {
        if !mainStore.notifications.newArtifacts.isEmpty {
            mainStore.notifications.newArtifacts.removeAll()
        }
    }

    /// Equip an artifact in the warehouse.
    func equip(_ artifact: Artifact) {
        let maxSlots = calculationService.maxArtifactSlots
        for index in 0..<maxSlots {
            if mainStore.warehouse.equippedSlots[index] == nil {
                mainStore.warehouse.equip(artifact, slot: index)
                return
            }
        }
    }

    /// Equip an artifact into a specific slot.
    func equip(_ artifact: Artifact, slot: Int) {
        mainStore.warehouse.equip(artifact, slot: slot)
    }

    /// Unequip an artifact in the warehouse.
    func unequip(_ artifact: Artifact) {
        mainStore.warehouse.unequip(artifact)
    }
    
    func details(item: BaseItem) -> ItemDetails {
        let doubleChance = calculationService
            .doubleItemChance(item: item)
            .percentageString()
        
        let researchLevel: Int?
        let researchCost: Int?
        if achievementService.isComplete(requirement: .upgradePurchased(.researchLab)) {
            researchLevel = mainStore.lab.currentLevel(item: item)
            researchCost = researchService.rushCost(for: item)
        } else {
            researchLevel = nil
            researchCost = nil
        }
        
        return ItemDetails(
            item: item,
            doubleChance: doubleChance,
            researchLevel: researchLevel,
            researchCost: researchCost,
        )
    }
}

