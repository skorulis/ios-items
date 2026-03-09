//Created by Alexander Skorulis on 9/3/2026.

import Knit
import KnitMacros
import Foundation
import Models

final class ClientRequestHandler {

    private let mainStore: MainStore
    private let itemGeneratorService: ItemGeneratorService
    private let recipeService: RecipeService
    private let warehouseService: WarehouseService
    private let upgradeService: UpgradeService

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        itemGeneratorService: ItemGeneratorService,
        recipeService: RecipeService,
        warehouseService: WarehouseService,
        upgradeService: UpgradeService
    ) {
        self.mainStore = mainStore
        self.itemGeneratorService = itemGeneratorService
        self.recipeService = recipeService
        self.warehouseService = warehouseService
        self.upgradeService = upgradeService
    }

    func handle(request: ItemsClientRequest) -> ItemsClientResponse {
        print("Handling request with ID: \(request.id)")
        let result = handle(request: request.payload)
        return ItemsClientResponse(id: request.id, payload: result)
    }
    
    @MainActor
    func handle(request: ItemsClientRequest.Payload) -> ItemsClientResponse.Payload {
        switch request {
        case .getItems:
            let itemsWithCount = BaseItem.allCases.reduce(into: [BaseItem: Int]()) { dict, item in
                let quantity = mainStore.warehouse.quantity(item)
                if quantity > 0 {
                    dict[item] = quantity
                }
            }
            return .items(itemsWithCount)

        case .makeItem:
            let recipe = recipeService.nextAvailable()
            let result = itemGeneratorService.makeAndStore(recipe: recipe)
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
            let available = PortalUpgrade.allCases.filter { upgrade in
                !mainStore.portalUpgrades.purchased.contains(upgrade)
            }
            return .upgrades(
                UpgradesPayload(
                    purchased: purchased,
                    available: available
                )
            )
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
        }
    }
    
    private func getAvailableActions() -> [GameAction] {
        return [.makeItem]
    }
    
    private func getAvailableData() -> [GameData] {
        var result: [GameData] = [.items]
        if mainStore.achievements.unlocked.contains(.artifact1) {
            result.append(.artifacts)
        }
        
        return result
    }
}
