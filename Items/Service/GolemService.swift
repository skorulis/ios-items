// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models
import Knit
import KnitMacros

final class GolemService {

    private let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

extension GolemService {
}

// MARK: - Missions

extension GolemService {

    func unlockedMissionLocations(from mapLocations: MapLocations) -> [MapLocation] {
        mapLocations.unlocked.sorted { $0.name < $1.name }
    }

    func missionSlot(at index: Int) -> GolemMissionSlot? {
        return mainStore.golems.slots[index]
    }

    /// Fraction of mission health still remaining (1 = full, 0 = depleted or complete).
    func missionHealthRemainingFraction(slotIndex: Int) -> Double {
        guard let slot = missionSlot(at: slotIndex) else { return 0 }
        if slot.phase == .complete { return 0 }
        let maxHealth = slot.stats.health
        guard slot.phase == .running,
              let remaining = slot.remainingHealth,
              maxHealth > 0
        else { return 0 }
        return min(1, max(0, Double(remaining) / Double(maxHealth)))
    }

    func setMissionLocation(slotIndex: Int, location: MapLocation) {
        var golems = mainStore.golems
        var slot = golems.slots[slotIndex] ?? .empty()
        guard slot.phase != .running else { return }
        slot.location = location
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    /// Starts a mission from setup or restarts after completion. Consumes 1 portal shard.
    func beginMission(slotIndex: Int) {
        var golems = mainStore.golems
        var slot = golems.slots[slotIndex] ?? .empty()
        guard slot.phase != .running else { return }
        guard mainStore.warehouse.quantity(.portalShard) >= 1 else { return }

        mainStore.warehouse.remove(item: .portalShard, quantity: 1)
        slot.start(date: Date())
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func cancelMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }
        guard slot.phase == .running else { return }

        slot.phase = .setup
        slot.remainingHealth = nil
        slot.enemies = []
        slot.nextEnemySpawnAt = nil
        slot.lastSimulatedAt = Date()
        slot.exploringDistanceMeters = 0
        slot.gainedItems = [:]
        slot.enemiesDefeated = 0
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

}

// MARK: - Cosmetic equipment

extension GolemService {

    func equipment(forGolem slotIndex: Int) -> [EquipmentSlot: EquipmentInstance] {
        mainStore.golems.equipmentByGolem[slotIndex]?.slots ?? [:]
    }

    /// Moves `instance` from the warehouse into the golem slot. Any previously equipped item returns to the warehouse.
    func equip(slotIndex: Int, instance: EquipmentInstance, to slot: EquipmentSlot) {
        guard instance.kind.slot == slot else { return }
        guard mainStore.warehouse.equipment.contains(where: { $0.id == instance.id }) else { return }

        var golems = mainStore.golems
        var loadout = golems.equipmentByGolem[slotIndex] ?? GolemEquipmentLoadout()
        let previous = loadout.slots[slot]

        mainStore.warehouse.equipment.removeAll { $0.id == instance.id }

        if let previous {
            appendToWarehouseIfRoom(previous)
        }

        loadout.slots[slot] = instance
        golems.equipmentByGolem[slotIndex] = loadout
        mainStore.golems = golems
    }

    func unequip(slotIndex: Int, slot: EquipmentSlot) {
        var golems = mainStore.golems
        guard var loadout = golems.equipmentByGolem[slotIndex] else { return }
        guard let instance = loadout.slots.removeValue(forKey: slot) else { return }

        appendToWarehouseIfRoom(instance)

        if loadout.slots.isEmpty {
            golems.equipmentByGolem.removeValue(forKey: slotIndex)
        } else {
            golems.equipmentByGolem[slotIndex] = loadout
        }
        mainStore.golems = golems
    }

    private func appendToWarehouseIfRoom(_ instance: EquipmentInstance) {
        guard mainStore.warehouse.equipment.count < 100 else { return }
        mainStore.warehouse.equipmentUnlocked = true
        mainStore.warehouse.equipment.append(instance)
    }

}
