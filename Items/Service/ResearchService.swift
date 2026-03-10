//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import Knit
import KnitMacros
import Models

final class ResearchService {

    private let mainStore: MainStore
    private let calculations: CalculationsService
    private let toastService: ToastService
    private var progressCheckTimer: Timer?

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, calculations: CalculationsService, toastService: ToastService) {
        self.mainStore = mainStore
        self.calculations = calculations
        self.toastService = toastService
    }

    /// Start a timer that every 1s applies research progress when there is active research. Call once from app launch so research completes even when not on the Research tab.
    func startProgressCheckTimer() {
        guard progressCheckTimer == nil else { return }
        progressCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.mainStore.lab.currentResearch != nil {
                self.updateResearchProgress(now: Date())
            }
        }
        RunLoop.main.add(progressCheckTimer!, forMode: .common)
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
    func updateResearchProgress(now: Date = Date(), forceSave: Bool = false) {
        var lab = mainStore.lab
        guard let current = lab.currentResearch else { return }
        let item = current.item
        
        let startDate = current.startDate
        let boostMultiplier = 1.0 + Double(calculations.researchSpeedBoostPercent()) / 100.0
        let liveElapsed = now.timeIntervalSince(startDate) * boostMultiplier
        var elapsed = lab.accumulatedSeconds(for: item) + liveElapsed
        var level = lab.currentLevel(item: item)
        
        var totalRequired = calculations.researchDurationSeconds(for: item, level: level)
        var saveRequired: Bool = forceSave
        while totalRequired > 0 && elapsed >= totalRequired {
            elapsed -= totalRequired
            level += 1
            lab.setState(level: level, accumulatedSeconds: 0, for: item)
            applyUnlocks(for: item, newLevel: level)
            totalRequired = calculations.researchDurationSeconds(for: item, level: level)
            saveRequired = true
        }
        guard saveRequired else { return }
        
        lab.setState(level: level, accumulatedSeconds: elapsed, for: item)
        lab.setCurrentResearch(item: item, startDate: now)
        mainStore.lab = lab
    }
    
    /// The number of items required to rush the current research level (1 item per minute of remaining time).
    func rushCost(for item: BaseItem, now: Date = Date()) -> Int {
        let (completed, total) = progressFor(item: item, now: now)
        let remainingSeconds = max(total - completed, 0)
        guard remainingSeconds > 0 else { return 0 }
        let remainingMinutes = remainingSeconds / 60
        return max(1, Int(ceil(remainingMinutes)))
    }
    
    /// Instantly completes the current research level for the given item by consuming items and applying unlocks.
    func rushResearch(to item: BaseItem, useBooks: Bool, now: Date = Date()) throws {
        var lab = mainStore.lab
        var warehouse = mainStore.warehouse
        
        let cost = rushCost(for: item, now: now)
        let consumedItem: BaseItem = useBooks ? .book : item
        guard cost > 0, warehouse.quantity(consumedItem) >= cost else {
            throw ItemsError(message: "Insufficient item count")
        }
        
        let currentLevel = lab.currentLevel(item: item)
        warehouse.remove(item: consumedItem, quantity: cost)
        
        let newLevel = currentLevel + 1
        lab.setState(level: newLevel, accumulatedSeconds: 0, for: item)
        lab.setCurrentResearch(item: item, startDate: now)
        applyUnlocks(for: item, newLevel: newLevel)
        
        mainStore.lab = lab
        mainStore.warehouse = warehouse
    }
    
    private func applyUnlocks(for item: BaseItem, newLevel: Int) {
        mainStore.notifications.recordNewResearchLevel()
        toastService.showToast("Researched \(item.name) to level \(newLevel)")
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
            let boostMultiplier = 1.0 + Double(calculations.researchSpeedBoostPercent()) / 100.0
            let liveElapsed = now.timeIntervalSince(start) * boostMultiplier
            return (min(accumulated + liveElapsed, total), total)
        }
        return (accumulated, total)
    }

    /// Research speed boost percent from equipped Perfect Lens (for UI).
    func researchSpeedBoostPercent() -> Int {
        calculations.researchSpeedBoostPercent()
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
        return .init(essences: self.essences, lore: lore)
    }
}
