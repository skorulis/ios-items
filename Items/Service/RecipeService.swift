//Created by Alexander Skorulis on 13/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import Models

final class RecipeService: ObservableObject {

    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var sacrificePlan: SacrificePlan

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.sacrificePlan = Self.computeSacrificePlan(recipes: mainStore.recipes, warehouse: mainStore.warehouse)

        mainStore.$warehouse
            .sink { [unowned self] in
                self.sacrificePlan = Self.computeSacrificePlan(recipes: self.mainStore.recipes, warehouse: $0)
            }
            .store(in: &cancellables)

        mainStore.$recipes
            .sink { [unowned self] in
                self.sacrificePlan = Self.computeSacrificePlan(recipes: $0, warehouse: self.mainStore.warehouse)
            }
            .store(in: &cancellables)
    }

    /// Resolves which item (if any) would be consumed from each sacrifice slot, in slot order.
    /// Uses `mainStore.recipes.sacrificeConfig` and current warehouse quantities.
    func sacrificeConsumptionPlan() -> SacrificePlan {
        Self.computeSacrificePlan(recipes: mainStore.recipes, warehouse: mainStore.warehouse)
    }

    /// Removes one warehouse unit per entry in the plan’s `consumedItems` order.
    func consumePlan(_ plan: SacrificePlan) {
        for item in plan.consumedItems {
            mainStore.warehouse.remove(item: item, quantity: 1)
        }
    }

    private static func computeSacrificePlan(recipes: Recipes, warehouse: Warehouse) -> SacrificePlan {
        if !recipes.sacrificesEnabled {
            return .init(itemsInOrder: [])
        }
        let config = recipes.sacrificeConfig
        var available: [BaseItem: Int] = [:]
        for item in BaseItem.allCases {
            available[item] = warehouse.quantity(item)
        }
        var result: [Int: BaseItem?] = [:]
        for index in 0..<SacrificeConfig.slotCount {
            guard let item = config.item(at: index) else {
                result[index] = nil
                continue
            }
            let qty = available[item, default: 0]
            if qty > 0 {
                result[index] = item
                available[item] = qty - 1
            } else {
                result[index] = nil
            }
        }
        return SacrificePlan(slotsByIndex: result)
    }
}
