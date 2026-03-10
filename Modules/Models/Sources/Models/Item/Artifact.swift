// Created by Alexander Skorulis on 15/2/2026.

import Foundation

public enum Artifact: Identifiable, Hashable, CaseIterable, Codable {
    case frictionlessGear
    case eternalHourglass
    case luckyCoin
    case perfectLens
    case sacrificalSkull
    case essenceFlask

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
        case .luckyCoin:
            return "A coin blessed with fortune, increasing the chance of double item rewards."
        case .perfectLens:
            return "A flawless lens that boosts research."
        case .sacrificalSkull:
            return "A grim relic that strengthens the effects of sacrifices."
        case .essenceFlask:
            return "A flask attuned to latent essences that attracts other artifacts"
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

    func eternalHourglassTimeReduction(quality: ItemQuality) -> Int {
        switch quality {
        case .junk: return 500
        case .common: return 1000
        case .good: return 1500
        case .rare: return 2000
        case .exceptional: return 2500
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
        case .eternalHourglass:
            return "Reduces automatic item creation time by \(eternalHourglassTimeReduction(quality: quality)) milliseconds"
        case .luckyCoin:
            return "Increase the chance of double items by \(luckyCoinMultipleItemChance(quality: quality))%"
        case .sacrificalSkull:
            return "Increase the effect of sacrifices by \(sacrificalSkullSacrificeEffectMultiplier(quality: quality))%"
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
        case .essenceFlask:
            return .artifactDiscovery(type.essenceFlaskArtifactDiscoveryBoost(quality: quality))
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
