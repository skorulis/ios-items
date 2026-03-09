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

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        itemGeneratorService: ItemGeneratorService,
        recipeService: RecipeService,
        warehouseService: WarehouseService
    ) {
        self.mainStore = mainStore
        self.itemGeneratorService = itemGeneratorService
        self.recipeService = recipeService
        self.warehouseService = warehouseService
    }

    @MainActor
    func handle(request: ItemsClientRequest) -> ItemsClientResponse {
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
        }
    }
}
