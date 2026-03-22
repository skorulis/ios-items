// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models
import Knit
import KnitMacros

final class GolemService {

    private let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

extension GolemService {

    func canPurchase(_ type: GolemType) -> Bool {
        type.cost.allSatisfy { mainStore.warehouse.quantity($0.item) >= $0.quantity }
    }

    func purchase(_ type: GolemType) {
        guard canPurchase(type) else { return }
        for costItem in type.cost {
            mainStore.warehouse.remove(item: costItem.item, quantity: costItem.quantity)
        }
        var next = mainStore.golemInventory
        next.counts[type, default: 0] += 1
        mainStore.golemInventory = next
    }
}
