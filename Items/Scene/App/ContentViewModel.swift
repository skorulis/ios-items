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
    private let offlineCreationService: OfflineCreationService
    private let toastService: ToastService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        achievementService: AchievementService,
        researchService: ResearchService,
        offlineCreationService: OfflineCreationService,
        toastService: ToastService
    ) {
        self.mainStore = mainStore
        self.achievementService = achievementService
        self.researchService = researchService
        self.offlineCreationService = offlineCreationService
        self.toastService = toastService
        
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
    
    /// Apply any research progress and offline creations that accrued while the app was backgrounded or closed.
    func onAppear() {
        researchService.startProgressCheckTimer()
        researchService.resumeResearchProgressIfNeeded()
        if let summary = offlineCreationService.processOfflineCreationsIfNeeded() {
            toastService.showToast(summary.toastMessage)
        }
    }

    /// Record that the app entered background so offline creation can be applied on return.
    func recordBackgrounded() {
        mainStore.offlineState = OfflineState(
            lastBackgroundedAt: Date(),
            automationEnabled: mainStore.offlineState.automationEnabled
        )
    }
}
