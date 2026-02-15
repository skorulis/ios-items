//Created by Alexander Skorulis on 15/2/2026.

import Foundation
import Knit
import KnitMacros

// Service for providing all sorts of shared calculations
struct CalculationsService {
    
    private let mainStore: MainStore
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
    
    var baseResearchChance: Double {
        return 0.2
    }
}
