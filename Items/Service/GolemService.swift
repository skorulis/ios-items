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

    func canPurchase(_ type: GolemType) -> Bool {
        type.cost.allSatisfy { mainStore.warehouse.quantity($0.item) >= $0.quantity }
    }

    func purchase(_ type: GolemType) {
        guard canPurchase(type) else { return }
        for costItem in type.cost {
            mainStore.warehouse.remove(item: costItem.item, quantity: costItem.quantity)
        }
        mainStore.golems.addOne(type)
    }
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
              let type = slot.golemType,
              let remaining = slot.remainingHealth,
              type.missionMaxHealth > 0
        else { return 0 }
        return min(1, max(0, Double(remaining) / Double(type.missionMaxHealth)))
    }

    func setReservedGolem(slotIndex: Int, newType: GolemType?) {
        var golems = mainStore.golems
        var slot = golems.slots[slotIndex] ?? .empty()
        guard slot.phase == .setup else { return }
        if slot.golemType == newType { return }

        if let previous = slot.golemType {
            golems.addOne(previous)
        }
        slot.golemType = nil
        golems.slots[slotIndex] = slot
        mainStore.golems = golems

        guard let desired = newType else { return }

        guard golems.removeOne(desired) else {
            return
        }
        slot.golemType = desired
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func setMissionLocation(slotIndex: Int, location: MapLocation?) {
        var golems = mainStore.golems
        var slot = golems.slots[slotIndex] ?? .empty()
        guard slot.phase == .setup else { return }
        slot.location = location
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func startMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }
        guard slot.phase == .setup,
              slot.golemType != nil,
              let location = slot.location,
              mainStore.mapLocations.isUnlocked(location)
        else { return }

        guard let golemType = slot.golemType else { return }
        slot.start(date: Date(), initialHealth: golemType.missionMaxHealth)
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func cancelMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }
        guard slot.phase == .running else { return }

        slot = .empty()
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func clearCompletedMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }
        guard slot.phase == .complete else { return }

        slot = .empty()
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }
}
