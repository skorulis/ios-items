// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

final class GolemMissionService {

    private let mainStore: MainStore
    private let itemGeneratorService: ItemGeneratorService
    private var progressCheckTimer: Timer?

    private static let enemyApproachDuration: TimeInterval = 2.4
    private static let exploringToGatheringChance = Chance(percent: 10)
    private static let exploringMetersPerTick = 1
    private static let golemAttackDamagePerTick = 4

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, itemGeneratorService: ItemGeneratorService) {
        self.mainStore = mainStore
        self.itemGeneratorService = itemGeneratorService
    }

    /// Start a 1s timer to advance running missions (exploring / gathering). Call once from app launch.
    func startProgressCheckTimer() {
        guard progressCheckTimer == nil else { return }
        progressCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.tickMissions(now: Date())
        }
        RunLoop.main.add(progressCheckTimer!, forMode: .common)
    }

    /// Run one tick (e.g. after foreground) so gathering can complete if wall time exceeded 3s.
    func resumeMissionProgressIfNeeded() {
        tickMissions(now: Date())
    }

    private func tickMissions(now: Date) {
        var golems = mainStore.golems
        var changed = false

        for index in golems.slots.keys {
            guard var slot = golems.slots[index],
                  slot.phase == .running
            else { continue }

            var slotMutated = false
            switch slot.missionActivityState {
            case .exploring:
                slot.exploringDistanceMeters += Self.exploringMetersPerTick
                slotMutated = true
                if let newState = checkForNewState(now: now) {
                    slot.setActivity(state: newState, date: now)
                    if case let .approachingEnemy(type, _, _, _, _) = newState {
                        slot.appendActivityLog("Encountered a \(type.displayName).", date: now)
                    }
                }
            case let .approachingEnemy(type, enemyMaxHealth, enemyRemainingHealth, _, contactAt):
                slot.exploringDistanceMeters += Self.exploringMetersPerTick
                slotMutated = true
                guard now >= contactAt else { break }
                slot.setActivity(
                    state: .combat(
                        type: type,
                        enemyMaxHealth: enemyMaxHealth,
                        enemyRemainingHealth: enemyRemainingHealth
                    ),
                    date: now
                )

            case let .combat(type, enemyMaxHealth, enemyRemainingHealth):
                let updatedEnemyHealth = max(0, enemyRemainingHealth - Self.golemAttackDamagePerTick)
                slot.takeDamage(type.damagePerTick)
                if updatedEnemyHealth == 0 {
                    slot.appendActivityLog("Defeated \(type.displayName).", date: now)
                    slot.setActivity(state: .exploring, date: now)
                } else {
                    slot.setActivity(
                        state: .combat(
                            type: type,
                            enemyMaxHealth: enemyMaxHealth,
                            enemyRemainingHealth: updatedEnemyHealth
                        ),
                        date: now
                    )
                }
                slotMutated = true
            }

            if checkDeath(slot: &slot, now: now) {
                slotMutated = true
                recordCompletedMissionExploredDistance(slot: slot)
            }

            if slotMutated {
                golems.slots[index] = slot
                changed = true
            }
        }

        if changed {
            mainStore.golems = golems
        }
    }

    private func checkForNewState(now: Date) -> GolemMissionSlot.MissionActivityState? {
        guard Self.exploringToGatheringChance.check() else {
            return nil
        }
        let enemyType = EnemyType.allCases.randomElement() ?? .slime
        return .approachingEnemy(
            type: enemyType,
            enemyMaxHealth: enemyType.maxHealth,
            enemyRemainingHealth: enemyType.maxHealth,
            approachStartedAt: now,
            contactAt: now.addingTimeInterval(Self.enemyApproachDuration)
        )
    }

    private func checkDeath(slot: inout GolemMissionSlot, now: Date) -> Bool {
        if slot.remainingHealth == 0 {
            slot.phase = .complete
            slot.appendActivityLog("golem died after travelling \(slot.exploringDistanceMeters)m", date: now)
            return true
        }
        return false
    }

    private func recordCompletedMissionExploredDistance(slot: GolemMissionSlot) {
        guard slot.phase == .complete else { return }
        let meters = slot.exploringDistanceMeters
        guard meters > 0 else { return }
        var mapLocations = mainStore.mapLocations
        mapLocations.addGolemExploredDistance(meters, for: slot.location)
        mainStore.mapLocations = mapLocations
        mainStore.statistics.golemDistanceTraveledMeters += Int64(meters)
    }
}
