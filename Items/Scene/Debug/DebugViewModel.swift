//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Knit
import KnitMacros

@Observable final class DebugViewModel {

    let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

// MARK: - Logic

extension DebugViewModel {

    func resetUpgrades() {
        mainStore.portalUpgrades = PortalUpgrades()
    }
    
    func addItems() {
        for item in BaseItem.allCases {
            mainStore.warehouse.add(item: item, count: 1)
        }
    }
}

