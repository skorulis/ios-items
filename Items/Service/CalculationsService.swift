//Created by Alexander Skorulis on 15/2/2026.

import Combine
import Foundation
import Knit
import Models
import KnitMacros

// Service for providing all sorts of shared calculations
final class CalculationsService: ObservableObject {
    
    private let mainStore: MainStore
    
    @Published var maxArtifactSlots: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        
        mainStore.$portalUpgrades.sink { [unowned self] portalUpgrades in
            self.updateMaxArtifactSlots(portalUpgrades: portalUpgrades)
        }
        .store(in: &cancellables)
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
        let base = 0.02 * quality.artifactChanceMultiplier
        let levelMultiplier = pow(2.0, Double(researchLevel))
        var chance = Chance(min(1.0, base * levelMultiplier))
        chance = chance.multiplying(percent: mainStore.warehouse.artifactBonuses.artifactDiscovery)
        return chance
    }

    private func updateMaxArtifactSlots(portalUpgrades: PortalUpgrades) {
        let value = portalUpgrades.bonuses.artifactSlots
        if value != maxArtifactSlots {
            maxArtifactSlots = value
        }
    }

    func researchSpeedBoostPercent() -> Int {
        var result = 0
        if let lens = mainStore.warehouse.equippedArtifact(.perfectLens) {
            result += lens.type.perfectLensResearchBoost(quality: lens.quality)
        }
        result += mainStore.portalUpgrades.bonuses.researchSpeed
        result += mainStore.achievements.bonuses.researchSpeed
        
        return result
    }
}
