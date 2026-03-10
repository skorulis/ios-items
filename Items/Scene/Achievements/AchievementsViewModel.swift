//Created by Alexander Skorulis on 16/2/2026.

import ASKCoordinator
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class AchievementsViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?
    
    private let mainStore: MainStore
    private let achievementService: AchievementService
    
    var model = AchievementsView.Model()
    
    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        achievementService: AchievementService
    ) {
        self.mainStore = mainStore
        self.achievementService = achievementService
    }
}

// MARK: - Logic

extension AchievementsViewModel {

    func isComplete(achievement: Achievement) -> Bool {
        mainStore.achievements.unlocked.contains(achievement)
    }
    
    // TODO: Make this data reactive
    func isVisible(achievement: Achievement) -> Bool {
        achievementService.isVisible(achievement: achievement)
    }
    
    func showDetails(achievement: Achievement) {
        model.newAchievementsToShow.remove(achievement)
        coordinator?.custom(overlay: .card, MainPath.achievementDetails(achievement))
    }
    
    func onAppear() {
        model.newAchievementsToShow = mainStore.notifications.newAchievements
        mainStore.notifications.clearNewAchievements()
    }
}
