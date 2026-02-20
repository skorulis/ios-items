//Created by Alexander Skorulis on 20/2/2026.

import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class AchievementDetailsViewModel {
    
    let achievement: Achievement
    
    var model: AchievementDetailsView.Model
    
    private let achievementService: AchievementService
    
    @Resolvable<BaseResolver>
    init(@Argument achievement: Achievement, achievementService: AchievementService) {
        self.achievement = achievement
        self.achievementService = achievementService
        self.model = .init(
            value: achievementService.progressValue(requirement: achievement.requirement),
            total: achievementService.progressTotal(requirement: achievement.requirement)
        )
        
        // TODO: Add observation
    }
}

// MARK: - Logic

extension AchievementDetailsViewModel {}
