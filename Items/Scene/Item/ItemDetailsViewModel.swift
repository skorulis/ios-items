//Created by Alexander Skorulis on 16/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ItemDetailsViewModel {
    
    let item: BaseItem
    var lab: Laboratory
    
    private let mainStore: MainStore
    private let calculations: CalculationsService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(@Argument item: BaseItem, mainStore: MainStore, calculations: CalculationsService) {
        self.item = item
        self.mainStore = mainStore
        self.calculations = calculations
        self.lab = mainStore.lab
        
        mainStore.$lab.sink { [unowned self] in
            self.lab = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ItemDetailsViewModel {
    
    var doubleChanceString: String {
        String(calculations.doubleItemChance(item: item))
    }
    
}
