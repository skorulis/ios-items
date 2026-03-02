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
    
    var autoCreationMilliseconds: Double {
        return 5000
    }
    
    var itemCreationMilliseconds: Double {
        var value: Double = 1000
        if let fg = mainStore.warehouse.artifactInstance(.frictionlessGear) {
            value -= Double(fg.type.frictionlessGearTimeReduction(quality: fg.quality))
        }
        
        return max(value, 100)
    }
    
    func doubleItemChance(item: BaseItem) -> Chance {
        let level = Double(mainStore.lab.currentLevel(item: item))
        return Chance(level * 0.05)
    }
    
    func artifactChance(quality: ItemQuality, researchLevel: Int) -> Chance {
        let base = 0.1 * quality.artifactChanceMultiplier
        let levelMultiplier = pow(2.0, Double(researchLevel))
        return Chance(min(1.0, base * levelMultiplier))
    }
}
