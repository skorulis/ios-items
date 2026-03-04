//Created by Alexander Skorulis on 16/2/2026.

import ASKCoordinator
import Knit
import KnitMacros
import SwiftUI

@Observable final class AchievementsViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?
    
    private let mainStore: MainStore
    
    var model = AchievementsView.Model()
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

// MARK: - Logic

extension AchievementsViewModel {

    func isComplete(achievement: Achievement) -> Bool {
        mainStore.achievements.unlocked.contains(achievement)
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
