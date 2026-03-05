//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Knit
import KnitMacros

@Observable final class DebugViewModel {

    private let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

// MARK: - Logic

extension DebugViewModel {

    /// Reset all purchased portal upgrades back to the default state.
    func resetUpgrades() {
        mainStore.portalUpgrades = PortalUpgrades()
    }
}

