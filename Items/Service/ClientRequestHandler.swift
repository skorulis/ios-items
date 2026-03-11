//Created by Alexander Skorulis on 9/3/2026.

import Knit
import KnitMacros
import Foundation
import Models

final class ClientRequestHandler {

    private let mainStore: MainStore
    private let achievementService: AchievementService
    private let unlockRequirementService: UnlockRequirementService
    private let itemGeneratorService: ItemGeneratorService
    private let recipeService: RecipeService
    private let warehouseService: WarehouseService
    private let upgradeService: UpgradeService
    private let researchService: ResearchService

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        achievementService: AchievementService,
        unlockRequirementService: UnlockRequirementService,
        itemGeneratorService: ItemGeneratorService,
        recipeService: RecipeService,
        warehouseService: WarehouseService,
        upgradeService: UpgradeService,
        researchService: ResearchService
    ) {
        self.mainStore = mainStore
        self.achievementService = achievementService
        self.unlockRequirementService = unlockRequirementService
        self.itemGeneratorService = itemGeneratorService
        self.recipeService = recipeService
        self.warehouseService = warehouseService
        self.upgradeService = upgradeService
        self.researchService = researchService
    }

    func handle(request: ItemsClientRequest) -> ItemsClientResponse {
        let result = handle(request: request.payload)
        return ItemsClientResponse(id: request.id, payload: result)
    }
    
    @MainActor
    func handle(request: ItemsClientRequest.Payload) -> ItemsClientResponse.Payload {
        switch request {
        case .getItems:
            let itemsWithDetails = BaseItem.allCases.reduce(into: [BaseItem: ItemWithDetails]()) { dict, item in
                let quantity = mainStore.warehouse.quantity(item)
                if mainStore.warehouse.hasDiscovered(item) {
                    let details = warehouseService.details(item: item)
                    dict[item] = ItemWithDetails(count: quantity, details: details)
                }
            }
            return .items(itemsWithDetails)

        case .makeItem:
            let plan = itemGeneratorService.sacrificeConsumptionPlan()
            recipeService.consumePlan(plan)
            let result = itemGeneratorService.makeAndStore(plan: plan)
            return .makeItemResult(result)
        case .getActions:
            return .actions(
                getAvailableActions(),
                getAvailableData(),
            )
        case .getArtifacts:
            let artifactsWithQuality = Artifact.allCases.reduce(into: [Artifact: ItemQuality]()) { dict, artifact in
                if let quality = mainStore.warehouse.quality(artifact) {
                    dict[artifact] = quality
                }
            }
            return .artifacts(artifactsWithQuality)
        case .getUpgrades:
            let purchased = Array(mainStore.portalUpgrades.purchased)
            let unlocked = PortalUpgrade.allCases.filter { upgrade in
                !mainStore.portalUpgrades.purchased.contains(upgrade)
                    && upgradeService.isUnlocked(upgrade)
            }
            let affordable = unlocked.filter { upgradeService.canPurchase($0) }
            return .upgrades(
                UpgradesPayload(
                    purchased: purchased,
                    unlocked: unlocked.filter { !upgradeService.canPurchase($0) },
                    affordable: affordable
                )
            )
        case .getAchievements:
            let unlocked = mainStore.achievements.unlocked
            let incompleteAchievements = Achievement.allCases
                .filter { !unlocked.contains($0) && achievementService.isVisible(achievement: $0) }
                .map { achievement in
                    IncompleteAchievement(
                        achievement: achievement,
                        currentProgress: unlockRequirementService.progressValue(requirement: achievement.requirement),
                        total: unlockRequirementService.progressTotal(requirement: achievement.requirement)
                    )
                }
            return .achievements(completed: Array(unlocked), incomplete: incompleteAchievements)
        case let .purchaseUpgrade(upgrade):
            if mainStore.portalUpgrades.purchased.contains(upgrade) {
                return .error("Upgrade already purchased")
            }
            if !upgradeService.isUnlocked(upgrade) {
                return .error("Upgrade is not unlocked")
            }
            if !upgradeService.canPurchase(upgrade) {
                return .error("Cannot afford upgrade")
            }
            upgradeService.purchase(upgrade)
            return .ok
        case let .buyResearch(item):
            do {
                try researchService.rushResearch(to: item, useBooks: false)
                return .ok
            } catch {
                return .error(error.localizedDescription)
            }
        }
    }
    
    private func getAvailableActions() -> [GameAction] {
        var result: [GameAction] = [.makeItem]
        if unlockRequirementService.isComplete(requirement: .upgradePurchased(.researchLab)) {
            result.append(.buyResearch)
        }
        if mainStore.achievements.unlocked.contains(.items10) {
            result.append(.purchaseUpgrade)
        }
        return result
    }
    
    private func getAvailableData() -> [GameData] {
        var result: [GameData] = [.items, .achievements]
        if mainStore.achievements.unlocked.contains(.artifact1) {
            result.append(.artifacts)
        }
        if mainStore.achievements.unlocked.contains(.items10) {
            result.append(.upgrades)
        }
        result.append(.achievements)

        return result
    }
}
