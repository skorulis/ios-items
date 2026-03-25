// Created by Alexander Skorulis on 3/3/2026.

import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

/// Service responsible for all mutations to `MainStore.warehouse`.
/// This ensures that changes always go through `MainStore` so persistence
/// and observers are correctly updated.
final class WarehouseService {

    private let mainStore: MainStore
    private let toastService: ToastService
    private let calculationService: CalculationsService
    private let unlockRequirementService: UnlockRequirementService
    private let researchService: ResearchService

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        toastService: ToastService,
        calculationService: CalculationsService,
        unlockRequirementService: UnlockRequirementService,
        researchService: ResearchService
    ) {
        self.mainStore = mainStore
        self.toastService = toastService
        self.calculationService = calculationService
        self.unlockRequirementService = unlockRequirementService
        self.researchService = researchService
    }
}

// MARK: - Public API

extension WarehouseService {

    /// Add items to the warehouse.
    func add(item: Ingredient, count: Int = 1) {
        let wasNewDiscovery = !mainStore.warehouse.hasDiscovered(item)
        mainStore.warehouse.add(item: item, count: count)
        if wasNewDiscovery {
            toastService.showToast(
                "Discovered \(item.name)",
                icon: AnyView(ItemView(item: item, size: .small)),
            )
            mainStore.notifications.recordNewItemDiscovery(item)
        }
    }

    /// Remove items from the warehouse.
    func remove(item: Ingredient, quantity: Int = 1) {
        mainStore.warehouse.remove(item: item, quantity: quantity)
    }

    /// Add / upgrade an artifact in the warehouse.
    func add(artifact: ArtifactInstance) {
        let wasNewDiscovery = mainStore.warehouse.isNewDiscovery(artifact: artifact)
        mainStore.warehouse.add(artifact: artifact)
        if wasNewDiscovery {
            let icon: AnyView = AnyView(ArtifactView(artifact: artifact, size: .small))
            if artifact.quality == .junk {
                toastService.showToast("Discovered \(artifact.type.name)", icon: icon)
            } else {
                toastService.showToast("Upgraded \(artifact.type.name)", icon: icon)
            }
            mainStore.notifications.recordNewArtifactDiscovery(artifact.type)
        }
    }

    func add(recipe: EquipmentRecipe) {
        let wasNewDiscovery = !mainStore.warehouse.recipes.contains(recipe)
        mainStore.warehouse.recipes.insert(recipe)
        if wasNewDiscovery {
            let icon = AnyView(
                AvatarView(
                    text: recipe.name,
                    image: Image(systemName: "list.bullet.clipboard"),
                    border: recipe.quality.color,
                    size: .small,
                ),
            )
            toastService.showToast("Discovered \(recipe.name)", icon: icon)
        }
    }

    /// Add a unique gear instance to the warehouse.
    func add(equipment: EquipmentInstance) {
        // Maximum 100 items in the inventory
        if mainStore.warehouse.equipment.count < 100 {
            mainStore.warehouse.equipmentUnlocked = true
            mainStore.warehouse.equipment.append(equipment)
        }
    }

    /// Mark an item as viewed so it no longer appears as new.
    func markItemViewed(_ item: Ingredient) {
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
        let firstEmpty = (0..<maxSlots).first { index in
            mainStore.warehouse.equippedSlots[index] == nil
        }
        if let firstEmpty {
            mainStore.warehouse.equip(artifact, slot: firstEmpty)
        } else {
            mainStore.warehouse.equip(artifact, slot: maxSlots - 1)
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

    func details(item: Ingredient) -> ItemDetails {
        let fraction = calculationService.multipleItemChanceFraction(item: item)
        let multipleItemChance = String(format: "%.1f%%", fraction * 100)

        let researchLevel: Int?
        let researchCost: Int?
        if unlockRequirementService.isComplete(requirement: .upgradePurchased(.researchLab)) {
            researchLevel = mainStore.lab.currentLevel(item: item)
            researchCost = researchService.rushCost(for: item)
        } else {
            researchLevel = nil
            researchCost = nil
        }

        let essences: [Essence?] = item.essences.enumerated().map { index, essence in
            guard let researchLevel else { return nil }
            return researchLevel > index ? essence : nil
        }

        return ItemDetails(
            item: item,
            doubleChance: multipleItemChance,
            researchLevel: researchLevel,
            researchCost: researchCost,
            essences: essences
        )
    }
}
