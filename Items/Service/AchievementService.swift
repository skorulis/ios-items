//Created by Alexander Skorulis on 16/2/2026.

import ASKCore
import Combine
import Foundation
import Knit
import KnitMacros

final class AchievementService {
    
    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        
        self.mainStore.objectWillChange.delayedChange().sink { [unowned self] _ in
            self.checkAchievements()
        }
        .store(in: &cancellables)
    }
    
    private func checkAchievements() {
        let toCheck = Achievement.allCases.filter { !mainStore.achievements.contains($0) }
        let completed = toCheck.filter { isComplete(requirement: $0.requirement) }
        mainStore.achievements = mainStore.achievements.union(completed)
    }
    
    func progressValue(requirement: UnlockRequirement) -> Int64 {
        switch requirement {
        case .itemsCreated:
            return mainStore.statistics.itemsCreated
        case .researchRuns:
            return mainStore.statistics.researchRuns
        case .commonItemsCreated:
            return Int64(mainStore.warehouse.totalItemsCollected { $0.quality == .common })
        case .essencesUnlocked:
            return Int64(mainStore.concepts.essences.count)
        case let .essenceUnlocked(essence):
            return mainStore.concepts.essences.contains(essence) ? 1 : 0
        }
    }
    
    func progressTotal(requirement: UnlockRequirement) -> Int64 {
        switch requirement {
        case let .itemsCreated(count),
             let .researchRuns(count),
             let .commonItemsCreated(count),
             let .essencesUnlocked(count):
            return count
            
        case .essenceUnlocked:
            return 1
        }
    }
    
    func isComplete(requirement: UnlockRequirement) -> Bool {
        return progressValue(requirement: requirement) >= progressTotal(requirement: requirement)
    }
}
