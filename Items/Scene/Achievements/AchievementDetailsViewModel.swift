//Created by Alexander Skorulis on 20/2/2026.

import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class AchievementDetailsViewModel {
    
    let achievement: Achievement
    
    var model: AchievementDetailsView.Model
    
    private let unlockRequirementService: UnlockRequirementService
    
    @Resolvable<BaseResolver>
    init(@Argument achievement: Achievement, unlockRequirementService: UnlockRequirementService) {
        self.achievement = achievement
        self.unlockRequirementService = unlockRequirementService
        self.model = .init(
            value: unlockRequirementService.progressValue(requirement: achievement.requirement),
            total: unlockRequirementService.progressTotal(requirement: achievement.requirement)
        )
        
        // TODO: Add observation
    }
}

// MARK: - Logic

extension AchievementDetailsViewModel {}
