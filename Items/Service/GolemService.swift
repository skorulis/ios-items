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

    func missionProgress(slotIndex: Int, at date: Date) -> Double {
        guard let slot = missionSlot(at: slotIndex),
              slot.phase == .running,
              let duration = slot.duration,
              duration > 0
        else { return 0 }
        return min(1, max(0, date.timeIntervalSince(slot.startedAt) / duration))
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

        slot.start(date: Date())
        slot.duration = GolemMissionTiming.defaultDuration
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func cancelMission(slotIndex: Int) {
        var golems = mainStore.golems
        guard var slot = golems.slots[slotIndex] else { return }

        if let golem = slot.golemType {
            golems.addOne(golem)
        }
        slot = .empty()
        golems.slots[slotIndex] = slot
        mainStore.golems = golems
    }

    func finalizeCompletedSlots(at date: Date) {
        var golems = mainStore.golems
        var changed = false

        for index in golems.slots.keys {
            var slot = golems.slots[index]!
            guard slot.phase == .running,
                  let golem = slot.golemType,
                  let duration = slot.duration,
                  date.timeIntervalSince(slot.startedAt) >= duration
            else { continue }

            golems.addOne(golem)
            slot = .empty()
            golems.slots[index] = slot
            changed = true
        }

        if changed {
            mainStore.golems = golems
        }
    }
}
