// Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Combine
import Knit
import KnitMacros
import Models

/// Service that evaluates unlock requirements against current game state.
/// Use this instead of AchievementService when you only need to check requirements.
final class UnlockRequirementService: ObservableObject {

    private let mainStore: MainStore
    @Published private(set) var calculator: UnlockRequirementCalculator
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.calculator = UnlockRequirementCalculator(
            warehouse: mainStore.warehouse,
            statistics: mainStore.statistics,
            lab: mainStore.lab,
            concepts: mainStore.concepts,
            portalUpgrades: mainStore.portalUpgrades,
            achievements: mainStore.achievements,
            mapLocations: mainStore.mapLocations
        )

        mainStore.$warehouse.sink { [weak self] in
            self?.calculator.warehouse = $0
        }
        .store(in: &cancellables)

        mainStore.$statistics.sink { [weak self] in
            self?.calculator.statistics = $0
        }
        .store(in: &cancellables)

        mainStore.$lab.sink { [weak self] in
            self?.calculator.lab = $0
        }
        .store(in: &cancellables)

        mainStore.$concepts.sink { [weak self] in
            self?.calculator.concepts = $0
        }
        .store(in: &cancellables)

        mainStore.$portalUpgrades.sink { [weak self] in
            self?.calculator.portalUpgrades = $0
        }
        .store(in: &cancellables)

        mainStore.$achievements.sink { [weak self] in
            self?.calculator.achievements = $0
        }
        .store(in: &cancellables)

        mainStore.$mapLocations.sink { [weak self] in
            self?.calculator.mapLocations = $0
        }
        .store(in: &cancellables)
    }

    func progressValue(requirement: UnlockRequirement) -> Int64 {
        calculator.progressValue(requirement: requirement)
    }

    func progressTotal(requirement: UnlockRequirement) -> Int64 {
        calculator.progressTotal(requirement: requirement)
    }

    func isComplete(requirement: UnlockRequirement) -> Bool {
        calculator.isComplete(requirement: requirement)
    }

}
