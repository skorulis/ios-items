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
        guard slot.phase == .running,
              let remaining = slot.remainingHealth,
              GolemMissionSlot.missionMaxHealth > 0
        else { return 0 }
        return min(1, max(0, Double(remaining) / Double(GolemMissionSlot.missionMaxHealth)))
    }

    func setMissionLocation(slotIndex: Int, location: MapLocation) {
        var golems = mainStore.golems
        var slot = golems.slots[slotIndex] ?? .empty()
        guard slot.phase != .running else { return }
        slot.location = location
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func startMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }
        guard slot.phase == .setup,
              mainStore.mapLocations.isUnlocked(slot.location)
        else { return }

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
        slot.activityLog = []
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func canRestartCompletedMission(slotIndex: Int) -> Bool {
        guard let slot = mainStore.golems.slots[slotIndex],
              slot.phase == .complete
        else { return false }
        return mainStore.warehouse.quantity(.portalShard) >= 1
    }

    func restartCompletedMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }
        guard slot.phase == .complete else { return }
        guard mainStore.mapLocations.isUnlocked(slot.location),
              mainStore.warehouse.quantity(.portalShard) >= 1
        else { return }

        mainStore.warehouse.remove(item: .portalShard, quantity: 1)
        slot.start(date: Date())
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }
}
