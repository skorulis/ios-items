// Created for offline creation support.

import Foundation
import Knit
import KnitMacros
import Models

final class OfflineCreationService {

    private let mainStore: MainStore
    private let recipeService: RecipeService
    private let itemGeneratorService: ItemGeneratorService
    private let calculations: CalculationsService

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        recipeService: RecipeService,
        itemGeneratorService: ItemGeneratorService,
        calculations: CalculationsService
    ) {
        self.mainStore = mainStore
        self.recipeService = recipeService
        self.itemGeneratorService = itemGeneratorService
        self.calculations = calculations
    }

    /// Process offline creations if automation was on and we have a stored background date.
    /// Returns a summary to show the user, or nil if nothing was applied.
    func processOfflineCreationsIfNeeded() -> OfflineSummary? {
        let state = mainStore.offlineState
        guard let lastBackgroundedAt = state.lastBackgroundedAt else {
            if state.lastBackgroundedAt != nil {
                mainStore.offlineState = OfflineState(
                    lastBackgroundedAt: nil,
                    automationEnabled: state.automationEnabled
                )
            }
            return nil
        }

        let now = Date()
        let maxOfflineTime = TimeInterval(mainStore.portalUpgrades.bonuses.offlineTimeMinutes * 60)
        let elapsed = min(now.timeIntervalSince(lastBackgroundedAt), maxOfflineTime)

        mainStore.offlineState = OfflineState(
            lastBackgroundedAt: nil,
            automationEnabled: state.automationEnabled
        )
        
        let cycleDuration = 5 * (calculations.autoCreationMilliseconds + calculations.itemCreationMilliseconds) / 1000
        let maxCreations = Int(elapsed / cycleDuration)
        let itemsCreatedBefore = mainStore.statistics.itemsCreated
        
        if maxCreations < 1 {
            return nil
        }

        for _ in 0 ..< maxCreations {
            let plan = recipeService.sacrificeConsumptionPlan()
            recipeService.consumePlan(plan)
            mainStore.statistics.itemsSacrificed += Int64(plan.consumedItems.count)
            _ = itemGeneratorService.makeAndStore(plan: plan)
        }

        let itemsCreated = mainStore.statistics.itemsCreated - itemsCreatedBefore
        mainStore.offlineState.updateBackgroundedTime()
        return OfflineSummary(awayDuration: elapsed, itemsCreated: itemsCreated)
    }
}

// MARK: - Inner Types

struct OfflineSummary {
    let awayDuration: TimeInterval
    let itemsCreated: Int64

    var toastMessage: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        let durationString = formatter.string(from: awayDuration) ?? "\(Int(awayDuration))s"
        return "You were away for \(durationString). \(itemsCreated) items were created."
    }
}
