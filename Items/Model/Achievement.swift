//Created by Alexander Skorulis on 16/2/2026.

import Foundation
import SwiftUI

enum Achievement: Codable, Hashable, CaseIterable, Identifiable {
    case items1
    case items10
    case items100
    case items1_000_000

    case sacrificed1
    case sacrificed1000

    case common1

    case artifact1
    case artifacts5

    case essence1
    case allEssences

    var id: Self { self }
    
    var name: String {
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
        case .essence1: return "First essence"
        case .allEssences: return "Essence master"
        }
    }
    
    var image: Image? {
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
        case .essence1:
            return Image(systemName: "leaf")
        case .allEssences:
            return Image(systemName: "leaf.fill")
        }
    }
    
    var requirement: UnlockRequirement {
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
        case .essence1:
            return .essencesUnlocked(1)
        case .allEssences:
            return .essencesUnlocked(Int64(Essence.allCases.count))
        }
    }
    
    var quality: ItemQuality {
        switch self {
        case .items1, .items10, .artifact1, .essence1, .sacrificed1:
            return .junk
        case .items100, .artifacts5, .common1, .allEssences, .sacrificed1000:
            return .common
        case .items1_000_000:
            return .exceptional
        }
    }
    
    var bonus: Bonus? {
        switch self {
        case .sacrificed1:
            return .qualityBoost(1, .common)
        case .common1:
            return .qualityBoost(1, .common)
        default:
            return nil
        }
    }
    
    var bonusMessage: String? {
        if let bonus {
            return bonus.text
        }
        switch self {
        case .items1: return nil
        case .items10:
            return "Unlocks research"
        case .items100:
            return "Unlocks sacrifices"
        case .artifact1:
            return "Unlocks artifact slots"
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
