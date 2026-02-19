//Created by Alexander Skorulis on 16/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ItemDetailsViewModel {
    
    var model: ItemDetailsView.Model
    
    private let mainStore: MainStore
    private let calculations: CalculationsService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(@Argument item: BaseItem, mainStore: MainStore, calculations: CalculationsService) {
        self.mainStore = mainStore
        self.calculations = calculations
        
        model = .init(item: item, lab: mainStore.lab, warehouse: mainStore.warehouse)
        
        mainStore.$lab.sink { [unowned self] in
            self.model.lab = $0
        }
        .store(in: &cancellables)
        
        mainStore.$warehouse.sink { [unowned self] in
            self.model.warehouse = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ItemDetailsViewModel {
    
    var doubleChanceString: String {
        String(calculations.doubleItemChance(item: model.item))
    }
    
}
