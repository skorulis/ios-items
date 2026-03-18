// Created by Alexander Skorulis on 21/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class EncyclopediaViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    let entry: EncyclopediaEntry
    private var unlockRequirementCalculator: UnlockRequirementCalculator
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(
        @Argument entry: EncyclopediaEntry,
        unlockRequirementService: UnlockRequirementService
    ) {
        self.entry = entry
        self.unlockRequirementCalculator = unlockRequirementService.calculator
        unlockRequirementService.$calculator.sink { [unowned self] in
            self.unlockRequirementCalculator = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension EncyclopediaViewModel {

    var backAction: (() -> Void)? {
        guard let coordinator,
              coordinator.canPop
        else { return nil }

        return { coordinator.pop() }
    }

    func isUnlocked(entry: EncyclopediaEntry) -> Bool {
        guard let condition = entry.condition else {
            return true
        }
        return unlockRequirementCalculator.isComplete(requirement: condition)
    }

    func showChild(entry: EncyclopediaEntry) {
        coordinator?.push(MainPath.encyclopediaEntry(entry))
    }

    func showStatistics() {
        coordinator?.push(MainPath.gameStatistics)
    }
}
