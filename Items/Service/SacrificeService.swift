// Created by Alexander Skorulis on 13/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import Models

final class SacrificeService: ObservableObject {

    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var sacrificePlan: SacrificePlan

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.sacrificePlan = Self.computeSacrificePlan(
            sacrifices: mainStore.sacrifices,
            warehouse: mainStore.warehouse,
            lab: mainStore.lab,
            location: mainStore.mapLocations.selected
        )

        mainStore.$warehouse
            .sink { [unowned self] in
                self.sacrificePlan = Self.computeSacrificePlan(
                    sacrifices: self.mainStore.sacrifices,
                    warehouse: $0,
                    lab: self.mainStore.lab,
                    location: self.mainStore.mapLocations.selected
                )
            }
            .store(in: &cancellables)

        mainStore.$sacrifices
            .sink { [unowned self] in
                self.sacrificePlan = Self.computeSacrificePlan(
                    sacrifices: $0,
                    warehouse: self.mainStore.warehouse,
                    lab: self.mainStore.lab,
                    location: self.mainStore.mapLocations.selected
                )
            }
            .store(in: &cancellables)

        mainStore.$lab
            .sink { [unowned self] in
                self.sacrificePlan = Self.computeSacrificePlan(
                    sacrifices: self.mainStore.sacrifices,
                    warehouse: self.mainStore.warehouse,
                    lab: $0,
                    location: self.mainStore.mapLocations.selected
                )
            }
            .store(in: &cancellables)
    }

    /// Resolves which item (if any) would be consumed from each sacrifice slot, in slot order.
    /// Uses `mainStore.sacrifices.sacrificeConfig` and current warehouse quantities.
    func sacrificeConsumptionPlan() -> SacrificePlan {
        Self.computeSacrificePlan(
            sacrifices: mainStore.sacrifices,
            warehouse: mainStore.warehouse,
            lab: mainStore.lab,
            location: mainStore.mapLocations.selected
        )
    }

    /// Removes one warehouse unit per entry in the plan’s `consumedItems` order.
    func consumePlan(_ plan: SacrificePlan) {
        for item in plan.consumedItems {
            mainStore.warehouse.remove(item: item, quantity: 1)
        }
    }

    private static func computeSacrificePlan(
        sacrifices: Sacrifices,
        warehouse: Warehouse,
        lab: Laboratory,
        location: MapLocation
    ) -> SacrificePlan {
        if !sacrifices.sacrificesEnabled {
            return .init(itemsInOrder: [], essences: [])
        }
        let config = sacrifices.sacrificeConfig
        var available: [Ingredient: Int] = [:]
        for item in Ingredient.allCases {
            available[item] = warehouse.quantity(item)
        }
        var result: [Int: Ingredient?] = [:]
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
        let consumedItems = result.keys.sorted().compactMap { result[$0] ?? nil }

        let essences = consumedItems.flatMap { item in
            item.availableResearch.unlockedEssences(level: lab.currentLevel(item: item))
        }

        var essenceMultipliers: [Essence: Double] = [:]
        for essence in essences {
            let value = essenceMultipliers[essence] ?? 1.0
            essenceMultipliers[essence] = value + 1
        }

        for (key, value) in location.details.essenceMultipliers {
            let oldValue = essenceMultipliers[key] ?? 1.0
            essenceMultipliers[key] = oldValue * value
        }

        return SacrificePlan(
            slotsByIndex: result,
            essences: essences,
            essenceMultipliers: essenceMultipliers,
        )
    }
}
