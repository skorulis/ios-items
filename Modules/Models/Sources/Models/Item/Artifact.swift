// Created by Alexander Skorulis on 15/2/2026.

import Foundation

public enum Artifact: Identifiable, Hashable, CaseIterable, Codable {
    case frictionlessGear
    case eternalHourglass
    case chargedQuartz
    case luckyCoin
    case perfectLens
    case sacrificalSkull
    case essenceFlask
    case skullOfStHermain

    public var id: Self { self }

    public var name: String {
        String(describing: self).fromCaseName
    }

    public var description: String {
        switch self {
        case .frictionlessGear:
            return "A gear that spins with no resistance, speeding up all item crafting."
        case .eternalHourglass:
            return "A timeless hourglass that accelerates automatic item creation."
        case .chargedQuartz:
            return "A glowing piece of quartz that emits a regular pulse"
        case .luckyCoin:
            return "A coin blessed with fortune, increasing the chance of duplicate item rewards."
        case .perfectLens:
            return "A flawless lens that boosts research."
        case .sacrificalSkull:
            return "A grim relic that strengthens the effects of sacrifices."
        case .essenceFlask:
            return "A flask attuned to latent essences that attracts other artifacts"
        case .skullOfStHermain:
            return "The skull of a priest known for brutal sacrifices to the dark god"
        }
    }
}

// MARK: - Bonuses

public extension Artifact {
    func frictionlessGearTimeReduction(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 100
        case .common: return 200
        case .good: return 300
        case .rare: return 400
        case .exceptional: return 500
        }
    }

    func luckyCoinMultipleItemChance(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 10
        case .common: return 20
        case .good: return 30
        case .rare: return 40
        case .exceptional: return 50
        }
    }

    func perfectLensResearchBoost(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 25
        case .common: return 50
        case .good: return 75
        case .rare: return 100
        case .exceptional: return 150
        }
    }

    func sacrificalSkullSacrificeEffectMultiplier(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 25
        case .common: return 50
        case .good: return 75
        case .rare: return 100
        case .exceptional: return 150
        }
    }

    /// Extra percentage multiplier applied to sacrifice bonuses.
    func skullOfStHermainSacrificeEffectMultiplier(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 20
        case .common: return 40
        case .good: return 60
        case .rare: return 80
        case .exceptional: return 100
        }
    }

    /// Extra percentage points added to artifact discovery/upgrade roll (same units as `Chance.adding(percent:)`).
    func essenceFlaskArtifactDiscoveryBoost(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 25
        case .common: return 50
        case .good: return 75
        case .rare: return 100
        case .exceptional: return 150
        }
    }
}

// MARK: - Bonus message

public extension Artifact {
    func bonusMessage(quality: ItemQuality) -> String {
        if let bonus = ArtifactInstance(type: self, quality: quality).bonus {
            return bonus.text
        }

        switch self {
        case .frictionlessGear:
            return "Reduces item creation time by \(frictionlessGearTimeReduction(quality: quality)) milliseconds."
        case .sacrificalSkull:
            return "Increase the effect of sacrifices by \(sacrificalSkullSacrificeEffectMultiplier(quality: quality))%"
        case .skullOfStHermain:
            return "Increase sacrifice bonuses by \(skullOfStHermainSacrificeEffectMultiplier(quality: quality))%"
        default:
            fatalError("Should be handled by a bonus")
        }
    }
}

public extension ArtifactInstance {
    var bonus: Bonus? {
        switch self.type {
        case .perfectLens:
            return .researchSpeed(type.perfectLensResearchBoost(quality: quality))
        case .eternalHourglass:
            let reduction: Int
            switch quality {
            case .junk: reduction = 500
            case .common: reduction = 750
            case .good: reduction = 1000
            case .rare: reduction = 1250
            case .exceptional: reduction = 1500
            }
            return .automaticItemCreationTimeReduction(reduction)
        case .chargedQuartz:
            let reduction: Int
            switch quality {
            case .junk: reduction = 750
            case .common: reduction = 1000
            case .good: reduction = 1250
            case .rare: reduction = 1500
            case .exceptional: reduction = 2000
            }
            return .automaticItemCreationTimeReduction(reduction)
        case .essenceFlask:
            return .artifactDiscovery(type.essenceFlaskArtifactDiscoveryBoost(quality: quality))
        case .luckyCoin:
            return .duplicateItemChance(type.luckyCoinMultipleItemChance(quality: quality))
        case .skullOfStHermain:
            return .sacrificePower(type.skullOfStHermainSacrificeEffectMultiplier(quality: quality))
        default:
            return nil
        }
    }
}

// MARK: -

public struct ArtifactInstance: Codable {
    public let type: Artifact
    public let quality: ItemQuality

    public var bonusMessage: String {
        type.bonusMessage(quality: quality)
    }

    public var name: String {
        return "\(quality.name) \(type.name)"
    }

    public init(type: Artifact, quality: ItemQuality) {
        self.type = type
        self.quality = quality
    }
}
