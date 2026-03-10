// Created by Alexander Skorulis on 16/2/2026.

import Foundation
import SwiftUI

public enum Achievement: String, Codable, Hashable, CaseIterable, Identifiable, Sendable {
    case items1
    case items10
    case items100
    case items1_000_000

    case sacrificed1
    case sacrificed1000

    case common1

    case artifact1
    case artifacts5

    case upgrade1
    case upgrade5

    case essence1
    case allEssences

    case research1
    case research10
    case research100

    case researchLevel5
    case researchLevel10

    public var id: Self { self }

    public var name: String {
        switch self {
        case .items1: return "Portal unlocked"
        case .items10: return "Baby steps"
        case .items100: return "Getting somewhere"
        case .items1_000_000: return "That's a lot"
        case .sacrificed1: return "First sacrifice"
        case .sacrificed1000: return "Mass sacrifice"
        case .common1: return "Filthy Commoner"
        case .artifact1: return "First artifact"
        case .artifacts5: return "Artifact collector"
        case .upgrade1: return "First upgrade"
        case .upgrade5: return "Upgrade enthusiast"
        case .essence1: return "First essence"
        case .allEssences: return "Essence master"
        case .research1: return "First research"
        case .research10: return "Apprentice researcher"
        case .research100: return "Master researcher"
        case .researchLevel5: return "Focused scholar"
        case .researchLevel10: return "Pioneer of knowledge"
        }
    }

    public var image: Image? {
        switch self {
        case .items1:
            return Image(systemName: "line.3.crossed.swirl.circle")
        case .items10:
            return Image(systemName: "waterbottle")
        case .items100:
            return Image(systemName: "gauge.with.dots.needle.bottom.100percent")
        case .common1:
            return Image(systemName: "command")
        case .items1_000_000:
            return Image(systemName: "gauge.with.dots.needle.100percent")
        case .sacrificed1:
            return Image(systemName: "flame")
        case .sacrificed1000:
            return Image(systemName: "flame.fill")
        case .artifact1:
            return Image(systemName: "sparkle")
        case .artifacts5:
            return Image(systemName: "sparkles.2")
        case .upgrade1:
            return Image(systemName: "arrow.up.circle")
        case .upgrade5:
            return Image(systemName: "arrow.up.circle.fill")
        case .essence1:
            return Image(systemName: "leaf")
        case .allEssences:
            return Image(systemName: "leaf.fill")
        case .research1:
            return Image(systemName: "lightbulb")
        case .research10:
            return Image(systemName: "lightbulb.min")
        case .research100:
            return Image(systemName: "lightbulb.max.fill")
        case .researchLevel5:
            return Image(systemName: "graduationcap")
        case .researchLevel10:
            return Image(systemName: "graduationcap.fill")
        }
    }

    public var requirement: UnlockRequirement {
        switch self {
        case .items1:
            return .itemsCreated(1)
        case .items10:
            return .itemsCreated(10)
        case .items100:
            return .itemsCreated(100)
        case .items1_000_000:
            return .itemsCreated(1_000_000)
        case .sacrificed1:
            return .itemsSacrificed(1)
        case .sacrificed1000:
            return .itemsSacrificed(1000)
        case .common1:
            return .commonItemsCreated(1)
        case .artifact1:
            return .artifactsUnlocked(1)
        case .artifacts5:
            return .artifactsUnlocked(5)
        case .upgrade1:
            return .upgradesPurchased(1)
        case .upgrade5:
            return .upgradesPurchased(5)
        case .essence1:
            return .essencesUnlocked(1)
        case .allEssences:
            return .essencesUnlocked(Int64(Essence.allCases.count))
        case .research1:
            return .totalResearch(1)
        case .research10:
            return .totalResearch(10)
        case .research100:
            return .totalResearch(100)
        case .researchLevel5:
            return .maxResearchLevel(5)
        case .researchLevel10:
            return .maxResearchLevel(10)
        }
    }

    /// When non-nil, this achievement is hidden until the condition is met.
    public var visibilityRequirement: UnlockRequirement? {
        switch self {
        case .sacrificed1, .sacrificed1000:
            return .upgradePurchased(.sacrifices)
        case .research1, .research10, .research100:
            return .upgradePurchased(.researchLab)
        case .researchLevel5, .researchLevel10:
            return .upgradePurchased(.researchLab)
        case .essence1, .allEssences:
            return .upgradePurchased(.researchLab)
        case .artifact1, .artifacts5:
            return .upgradePurchased(.researchLab)
        default:
            return nil
        }
    }

    public var quality: ItemQuality {
        switch self {
        case .items1, .items10, .artifact1, .essence1, .sacrificed1, .upgrade1, .research1, .research10, .researchLevel5:
            return .junk
        case .items100, .artifacts5, .common1, .allEssences, .sacrificed1000, .upgrade5, .research100, .researchLevel10:
            return .common
        case .items1_000_000:
            return .exceptional
        }
    }

    public var bonus: Bonus? {
        switch self {
        case .sacrificed1:
            return .qualityBoost(1, .common)
        case .common1:
            return .qualityBoost(1, .common)
        case .researchLevel5:
            return .researchSpeed(5)
        default:
            return nil
        }
    }

    public var bonusMessage: String? {
        if let bonus {
            return bonus.text
        }
        switch self {
        case .items1: return nil
        case .items10:
            return "Unlocks portal upgrades"
        case .items100:
            return "Unlocks sacrifices"
        case .artifact1:
            return "Unlocks artifact slot upgrade"
        case .artifacts5:
            return "Unlock second artifact slot"
        case .essence1:
            return "Encyclopedia entry unlocked"
        case .items1_000_000:
            return "TODO"
        default:
            return nil
        }
    }
}
