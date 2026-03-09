//Created by Alexander Skorulis on 10/2/2026.

import Combine
import Foundation
import Models
import Knit
import KnitMacros
import SwiftUI

@Observable final class ContentViewModel {
    
    var model: ContentView.Model = .init()

    private let mainStore: MainStore
    private let achievementService: AchievementService
    private let researchService: ResearchService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, achievementService: AchievementService, researchService: ResearchService) {
        self.mainStore = mainStore
        self.achievementService = achievementService
        self.researchService = researchService
        
        mainStore.$achievements.sink { achievements in
            self.model.showingAchievements = achievements.unlocked.count > 0
            self.model.showingEncyclopedia = achievements.unlocked.count > 0
            self.model.showingWarehouse = achievements.unlocked.contains(.items1)
        }
        .store(in: &cancellables)

        mainStore.$notifications
            .sink { [weak self] in self?.model.notifications = $0 }
            .store(in: &cancellables)

        self.model.notifications = mainStore.notifications
    }
}

// MARK: - Logic

extension ContentViewModel {
    
    /// Apply any research progress that accrued while the app was backgrounded or closed.
    func resumeResearchProgressIfNeeded() {
        researchService.startProgressCheckTimer()
        researchService.resumeResearchProgressIfNeeded()
    }
}
