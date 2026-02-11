//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Knit
import KnitMacros
import SwiftUI

@Observable final class WarehouseViewModel: CoordinatorViewModel {
    
    var coordinator: Coordinator?
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        
    }
}

// MARK: - Logic

extension WarehouseViewModel {}
