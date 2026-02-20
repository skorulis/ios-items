//Created by Alexander Skorulis on 10/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ContentViewModel {
    
    private(set) var showingResearch: Bool = false
    private(set) var showingAchievements: Bool = false
    
    private let achievementService: AchievementService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, achievementService: AchievementService) {
        self.achievementService = achievementService
        
        mainStore.$achievements.sink { achievements in
            self.showingAchievements = achievements.count > 0
            self.showingResearch = achievements.contains(.items10)
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ContentViewModel {
    
}
