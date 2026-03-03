//Created by Alexander Skorulis on 10/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ContentViewModel {
    
    private(set) var showingResearch: Bool = false
    private(set) var showingAchievements: Bool = false
    private(set) var warehouseNewCount: Int = 0
    private(set) var achievementsNewCount: Int = 0
    
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
            self.showingAchievements = achievements.unlocked.count > 0
            self.showingResearch = achievements.unlocked.contains(.items10)
        }
        .store(in: &cancellables)
        
        mainStore.$achievements
            .map(\.new.count)
            .sink { [weak self] in self?.achievementsNewCount = $0 }
            .store(in: &cancellables)
        
        mainStore.$warehouse
            .map(\.newDiscoveriesCount)
            .sink { [weak self] in self?.warehouseNewCount = $0 }
            .store(in: &cancellables)
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
