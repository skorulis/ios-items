// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

final class GolemMissionService {

    private let mainStore: MainStore
    private let itemGeneratorService: ItemGeneratorService
    private var progressCheckTimer: Timer?

    private static let golemAttackDamagePerTick = 4
    private static let tickInterval: TimeInterval = 1.0

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, itemGeneratorService: ItemGeneratorService) {
        self.mainStore = mainStore
        self.itemGeneratorService = itemGeneratorService
    }

    /// Start a fixed-time simulation timer for running missions. Call once from app launch.
    func startProgressCheckTimer() {
        guard progressCheckTimer == nil else { return }
        progressCheckTimer = Timer.scheduledTimer(withTimeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
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
            // 1) Spawn enemy if due (up to 3 total).
            if spawnEnemyIfDue(now: now, slot: &slot) {
                slotMutated = true
            }

            // 2) Move golem until an enemy reaches attack range.
            let anyEnemyInRange = slot.enemies.contains { $0.distanceToGolemMeters <= GolemMissionSlot.enemyAttackRangeMeters }
            if !anyEnemyInRange {
                slot.exploringDistanceMeters += Int(GolemMissionSlot.golemMetersPerTick.rounded())
                slotMutated = true
            }

            // 3) Move enemies closer (enemy runs towards the golem even while golem is fighting).
            if !slot.enemies.isEmpty {
                for i in slot.enemies.indices {
                    guard slot.enemies[i].remainingHealth > 0 else { continue }
                    let golemSpeed = anyEnemyInRange ? 0.0 : GolemMissionSlot.golemMetersPerTick
                    let closingSpeed = GolemMissionSlot.enemyMetersPerTick + golemSpeed
                    let newDistance = slot.enemies[i].distanceToGolemMeters - closingSpeed
                    slot.enemies[i].distanceToGolemMeters = max(
                        GolemMissionSlot.enemyAttackRangeMeters,
                        newDistance
                    )
                }
                slotMutated = true
            }

            // 4) Combat: any enemy in range fights back; golem attacks all in range.
            var enemiesInRangeIndices: [Int] = []
            for (index, enemy) in slot.enemies.enumerated() {
                guard enemy.remainingHealth > 0 else { continue }
                guard enemy.distanceToGolemMeters <= GolemMissionSlot.enemyAttackRangeMeters else { continue }
                enemiesInRangeIndices.append(index)
            }

            if !enemiesInRangeIndices.isEmpty {
                var totalDamageToGolem = 0
                for enemyIndex in enemiesInRangeIndices {
                    totalDamageToGolem += slot.enemies[enemyIndex].type.damagePerTick
                }

                // Apply golem damage.
                for enemyIndex in enemiesInRangeIndices {
                    let enemy = slot.enemies[enemyIndex]
                    slot.enemies[enemyIndex].remainingHealth = max(
                        0,
                        enemy.remainingHealth - Self.golemAttackDamagePerTick
                    )
                }

                slot.takeDamage(totalDamageToGolem)
                slotMutated = true

                // Remove defeated enemies and roll loot.
                let defeated = slot.enemies.filter {
                    $0.remainingHealth <= 0 && $0.distanceToGolemMeters <= GolemMissionSlot.enemyAttackRangeMeters
                }
                if !defeated.isEmpty {
                    slot.enemiesDefeated += defeated.count
                    for enemy in defeated {
                        let drop = enemy.type.rollDrop()
                        slot.gainedItems[drop, default: 0] += 1
                    }
                    slotMutated = true
                }
                slot.enemies.removeAll { $0.remainingHealth <= 0 }
            }

            if checkDeath(slot: &slot, now: now) {
                slotMutated = true
                recordCompletedMissionExploredDistance(slot: slot)
            }

            slot.lastSimulatedAt = now

            if slotMutated {
                golems.slots[index] = slot
                changed = true
            }
        }

        if changed {
            mainStore.golems = golems
        }
    }

    private func spawnEnemyIfDue(now: Date, slot: inout GolemMissionSlot) -> Bool {
        guard slot.enemies.count < GolemMissionSlot.maxEnemies else { return false }

        guard let nextAt = slot.nextEnemySpawnAt else {
            slot.nextEnemySpawnAt = now.addingTimeInterval(Double.random(in: 1.0 ... 2.5))
            return true
        }

        guard now >= nextAt else { return false }

        let enemyType = EnemyType.allCases.randomElement() ?? .slime
        slot.enemies.append(
            GolemMissionSlot.Enemy(
                type: enemyType,
                maxHealth: enemyType.maxHealth,
                remainingHealth: enemyType.maxHealth,
                distanceToGolemMeters: GolemMissionSlot.enemySpawnDistanceMeters
            )
        )
        slot.scheduleNextEnemySpawn(from: now)
        return true
    }

    private func checkDeath(slot: inout GolemMissionSlot, now: Date) -> Bool {
        if slot.remainingHealth == 0 {
            slot.phase = .complete
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
