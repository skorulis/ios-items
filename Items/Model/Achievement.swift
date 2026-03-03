//Created by Alexander Skorulis on 16/2/2026.

import Foundation
import SwiftUI

enum Achievement: Codable, Hashable, CaseIterable, Identifiable {
    case items10
    case items100
    case items1_000_000
    
    case common1

    case artifact1
    case artifacts5

    var id: Self { self }
    
    var name: String {
        switch self {
        case .items10: return "Baby steps"
        case .items100: return "Getting somewhere"
        case .items1_000_000: return "That's a lot"
        case .common1: return "Filthy Commoner"
        case .artifact1: return "First artifact"
        case .artifacts5: return "Artifact collector"
        }
    }
    
    var image: Image? {
        switch self {
        case .items10:
            return Image(systemName: "waterbottle")
        case .items100:
            return Image(systemName: "gauge.with.dots.needle.bottom.100percent")
        case .common1:
            return Image(systemName: "command")
        case .items1_000_000:
            return Image(systemName: "gauge.with.dots.needle.100percent")
        case .artifact1:
            return Image(systemName: "sparkle")
        case .artifacts5:
            return Image(systemName: "sparkles.2")
        }
    }
    
    var requirement: UnlockRequirement {
        switch self {
        case .items10:
            return .itemsCreated(10)
        case .items100:
            return .itemsCreated(100)
        case .items1_000_000:
            return .itemsCreated(1_000_000)
        case .common1:
            return .commonItemsCreated(1)
        case .artifact1:
            return .artifactsUnlocked(1)
        case .artifacts5:
            return .artifactsUnlocked(5)
        }
    }
    
    var quality: ItemQuality {
        switch self {
        case .items10:
            return .junk
        case .items100:
            return .common
        case .items1_000_000:
            return .exceptional
        case .common1:
            return .common
        case .artifact1:
            return .junk
        case .artifacts5:
            return .common
        }
    }
    
    var bonusMessage: String? {
        switch self {
        case .items10:
            return "Unlocks research"
        case .items100:
            return "Unlocks sacrifices"
        case .common1:
            return "1% increased chance to find common items"
        case .items1_000_000:
            return "TODO"
        case .artifact1, .artifacts5:
            return nil
        }
    }
    
}
