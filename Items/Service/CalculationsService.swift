// Created by Alexander Skorulis on 15/2/2026.

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
        return baseDuration * pow(1.5, Double(level))
    }

    var autoCreationMilliseconds: Double {
        let base: Double = 5000
        let reduction = Double(mainStore.warehouse.artifactBonuses.automaticItemCreationTimeReductionMilliseconds)
        let value = base - reduction
        return max(value, 100)
    }

    var itemCreationMilliseconds: Double {
        var value: Double = 1000
        if let fg = mainStore.warehouse.artifactInstance(.frictionlessGear) {
            value -= Double(fg.type.frictionlessGearTimeReduction(quality: fg.quality))
        }

        return max(value, 100)
    }

    /// Raw multiple-item chance as a fraction (e.g. 1.5 = 150% = 1 guaranteed extra + 50% for another).
    /// Use this for determining how many items to create; can exceed 1.
    func multipleItemChanceFraction(item: BaseItem) -> Double {
        let level = Double(mainStore.lab.currentLevel(item: item))
        var fraction = (1 + level) * 0.05
        if let coin = mainStore.warehouse.equippedArtifact(.luckyCoin) {
            fraction += Double(coin.type.luckyCoinMultipleItemChance(quality: coin.quality)) / 100
        }
        fraction += Double(mainStore.portalUpgrades.bonuses.multipleItemChance) / 100
        fraction += Double(mainStore.achievements.bonuses.multipleItemChance) / 100
        return max(0, fraction)
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
