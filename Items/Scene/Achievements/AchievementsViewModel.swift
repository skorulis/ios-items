//Created by Alexander Skorulis on 16/2/2026.

import ASKCoordinator
import Knit
import KnitMacros
import SwiftUI

@Observable final class AchievementsViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?
    
    private let mainStore: MainStore
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

// MARK: - Logic

extension AchievementsViewModel {
    
    func isComplete(achievement: Achievement) -> Bool {
        mainStore.achievements.contains(achievement)
    }
    
    func showDetails(achievement: Achievement) {
        coordinator?.custom(overlay: .card, MainPath.achievementDetails(achievement))
    }
}
