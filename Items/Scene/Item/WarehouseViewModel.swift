//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Knit
import KnitMacros
import SwiftUI

@Observable final class WarehouseViewModel: CoordinatorViewModel {
    
    var coordinator: Coordinator?
    
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    
    private var cancellables: Set<AnyCancellable> = []
    
    var detailsItem: BaseItem?
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        warehouse = mainStore.warehouse
        lab = mainStore.lab
        
        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)
        
        mainStore.$lab.sink { [unowned self] in
            self.lab = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension WarehouseViewModel {
    
    func pressed(item: BaseItem) {
        detailsItem = item
    }
}
