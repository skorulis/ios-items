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
    
    /// Seconds required to complete the current research level (2 min base, doubles per level).
    func researchDurationSeconds(for item: BaseItem) -> TimeInterval {
        let level = mainStore.lab.currentLevel(item: item)
        return researchDurationSeconds(for: item, level: level)
    }
    
    func researchDurationSeconds(for item: BaseItem, level: Int) -> TimeInterval {
        let baseDuration: TimeInterval = 120
        return baseDuration * pow(2.0, Double(level))
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
        var chance = Chance(level * 0.05)
        if let coin = mainStore.warehouse.equippedArtifact(.luckyCoin) {
            chance = chance.adding(percent: coin.type.luckyCoinMultipleItemChance(quality: coin.quality))
        }
        return chance
    }
    
    func artifactChance(quality: ItemQuality, researchLevel: Int) -> Chance {
        let base = 0.1 * quality.artifactChanceMultiplier
        let levelMultiplier = pow(2.0, Double(researchLevel))
        return Chance(min(1.0, base * levelMultiplier))
    }

    /// Research speed boost from equipped Perfect Lens (0 if none equipped).
    func researchSpeedBoostPercent() -> Int {
        guard let lens = mainStore.warehouse.equippedArtifact(.perfectLens) else { return 0 }
        return lens.type.perfectLensResearchBoost(quality: lens.quality)
    }
}
