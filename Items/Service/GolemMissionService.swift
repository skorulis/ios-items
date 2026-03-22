// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

final class GolemMissionService {

    private let mainStore: MainStore
    private let itemGeneratorService: ItemGeneratorService
    private var progressCheckTimer: Timer?

    /// Wall time spent in gathering before generating items.
    private static let gatheringDuration: TimeInterval = 3
    private static let exploringToGatheringChance = Chance(percent: 10)

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
                if Self.exploringToGatheringChance.check() {
                    slot.setActivity(state: .gathering, date: now)
                    slotMutated = true
                }

            case .gathering:
                let start = slot.activityStartDate
                if now.timeIntervalSince(start) >= Self.gatheringDuration {
                    let hadMissionLocation = slot.location != nil
                    let previousSelected = mainStore.mapLocations.selected
                    if let missionLocation = slot.location {
                        var mapLocations = mainStore.mapLocations
                        mapLocations.selected = missionLocation
                        mainStore.mapLocations = mapLocations
                    }

                    let results = itemGeneratorService.makeAndStore(
                        plan: SacrificePlan(slotsByIndex: [:]),
                        allowArtifacts: false,
                    )

                    if hadMissionLocation {
                        var mapLocations = mainStore.mapLocations
                        mapLocations.selected = previousSelected
                        mainStore.mapLocations = mapLocations
                    }

                    slot.add(results: results)
                    slot.setActivity(state: .exploring, date: now)
                    slotMutated = true
                }
            }

            if slot.phase == .running, let health = slot.remainingHealth, health > 0 {
                slot.remainingHealth = health - 1
                if slot.remainingHealth == 0 {
                    slot.phase = .complete
                }
                slotMutated = true
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
}
