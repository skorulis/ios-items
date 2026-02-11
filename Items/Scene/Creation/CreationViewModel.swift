//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class CreationViewModel {
    
    private let itemGeneratorService: ItemGeneratorService
    private let mainStore: MainStore
    
    @Resolvable<BaseResolver>
    init(itemGeneratorService: ItemGeneratorService, mainStore: MainStore) {
        self.itemGeneratorService = itemGeneratorService
        self.mainStore = mainStore
    }
}

// MARK: - Logic

extension CreationViewModel {
    
    func make() {
        let item = itemGeneratorService.make()
        mainStore.warehouse.add(item: item)
        mainStore.statistics.itemsCreated += 1
    }
    
}
