//Created by Alexander Skorulis on 21/2/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class EncyclopediaViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?
    
    let entry: EncyclopediaEntry
    private let unlockRequirementService: UnlockRequirementService
    
    @Resolvable<BaseResolver>
    init(
        @Argument entry: EncyclopediaEntry,
        unlockRequirementService: UnlockRequirementService
    ) {
        self.entry = entry
        self.unlockRequirementService = unlockRequirementService
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
        return unlockRequirementService.isComplete(requirement: condition)
    }
    
    func showChild(entry: EncyclopediaEntry) {
        coordinator?.push(MainPath.encyclopediaEntry(entry))
    }

    func showStatistics() {
        coordinator?.push(MainPath.gameStatistics)
    }
}
