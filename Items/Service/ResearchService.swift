//Created by Alexander Skorulis on 13/2/2026.

import Knit
import KnitMacros
import Foundation

final class ResearchService {
    
    private let mainStore: MainStore
    private let calculations: CalculationsService
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, calculations: CalculationsService) {
        self.mainStore = mainStore
        self.calculations = calculations
    }
}

extension ResearchService {
    
    /// Start or switch research to the given item. Pauses any other item's current progress.
    func startResearch(to item: BaseItem, now: Date = Date()) {
        // Apply any level-ups for the currently active item before pausing
        updateResearchProgress(now: now)
        
        mainStore.lab.setCurrentResearch(item: item, startDate: now)
    }
    
    /// Apply elapsed time to current research, level up when thresholds are met, persist remainder.
    func updateResearchProgress(now: Date = Date()) {
        var lab = mainStore.lab
        guard let current = lab.currentResearch else { return }
        let item = current.item
        
        let startDate = current.startDate
        var elapsed = now.timeIntervalSince(startDate) + lab.accumulatedSeconds(for: item)
        var level = lab.currentLevel(item: item)
        
        var totalRequired = calculations.researchDurationSeconds(for: item, level: level)
        while totalRequired > 0 && elapsed >= totalRequired {
            elapsed -= totalRequired
            level += 1
            lab.setState(level: level, accumulatedSeconds: 0, for: item)
            applyUnlocks(for: item, newLevel: level)
            totalRequired = calculations.researchDurationSeconds(for: item, level: level)
        }
        
        lab.setState(level: level, accumulatedSeconds: elapsed, for: item)
        lab.setCurrentResearch(item: item, startDate: now)
        mainStore.lab = lab
    }
    
    private func applyUnlocks(for item: BaseItem, newLevel: Int) {
        let essences = item.availableResearch.unlockedEssences(level: newLevel)
        for e in essences {
            mainStore.concepts.essences.insert(e)
        }
    }
    
    /// Progress toward the next research level for the given item (completed seconds, total seconds for current level).
    func progressFor(item: BaseItem, now: Date = Date()) -> (completed: TimeInterval, total: TimeInterval) {
        let lab = mainStore.lab
        let total = calculations.researchDurationSeconds(for: item)
        
        let accumulated = lab.accumulatedSeconds(for: item)
        if let current = lab.currentResearch, current.item == item {
            let start = current.startDate
            let liveElapsed = now.timeIntervalSince(start)
            return (min(accumulated + liveElapsed, total), total)
        }
        return (accumulated, total)
    }
    
    /// Call on app launch or when returning to foreground to catch up research progress.
    func resumeResearchProgressIfNeeded() {
        updateResearchProgress(now: Date())
    }
}

private enum ResearchType {
    case essence, lore
}

extension BaseItem {
    
    var availableResearch: Research {
        return .init(
            essences: self.essences,
            artifact: self.associatedArtifact != nil,
            lore: lore,
        )
    }
}
