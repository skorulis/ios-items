//Created by Alexander Skorulis on 16/2/2026.

import ASKCore
import Combine
import Foundation
import Knit
import KnitMacros
import Models

final class AchievementService {

    private let mainStore: MainStore
    private let unlockRequirementService: UnlockRequirementService
    private let toastService: ToastService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        unlockRequirementService: UnlockRequirementService,
        toastService: ToastService
    ) {
        self.mainStore = mainStore
        self.unlockRequirementService = unlockRequirementService
        self.toastService = toastService

        self.mainStore.objectWillChange.delayedChange().sink { [unowned self] _ in
            self.checkAchievements()
        }
        .store(in: &cancellables)
    }

    private func checkAchievements() {
        let toCheck = Achievement.allCases.filter { !mainStore.achievements.unlocked.contains($0) }
        let completed = toCheck.filter { unlockRequirementService.isComplete(requirement: $0.requirement) }
        guard completed.count > 0 else { return }
        let newAchievements = Set(completed)
        mainStore.achievements.add(achievements: newAchievements)
        mainStore.notifications.recordNewAchievements(newAchievements)
        for achievement in completed {
            toastService.showToast("Achievement unlocked: \(achievement.name)")
        }
    }

    func isVisible(achievement: Achievement) -> Bool {
        guard let requirement = achievement.visibilityRequirement else {
            return true
        }
        return unlockRequirementService.isComplete(requirement: requirement)
    }
}
