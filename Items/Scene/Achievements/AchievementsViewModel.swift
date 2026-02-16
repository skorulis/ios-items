//Created by Alexander Skorulis on 16/2/2026.

import ASKCoordinator
import Knit
import KnitMacros
import SwiftUI

@Observable final class AchievementsViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?
    
    @Resolvable<BaseResolver>
    init() {
        
    }
}

// MARK: - Logic

extension AchievementsViewModel {
    
    func showDetails(achievement: Achievement) {
        coordinator?.custom(overlay: .card, MainPath.achievementDetails(achievement))
    }
}
