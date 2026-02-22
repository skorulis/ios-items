//Created by Alexander Skorulis on 16/2/2026.

import Foundation
import SwiftUI

enum Achievement: Codable, Hashable, CaseIterable, Identifiable {
    case items1
    case items10
    case items100
    case items1_000_000
    
    case common1
    
    var id: Self { self }
    
    var name: String {
        switch self {
        case .items1: return "Your first item"
        case .items10: return "Baby steps"
        case .items100: return "Getting somewhere"
        case .items1_000_000: return "That's a lot"
        case .common1: return "Filthy Commoner"
        }
    }
    
    var image: Image? {
        switch self {
        case .items1:
            return Image(systemName: "1.circle")
        case .items10:
            return Image(systemName: "waterbottle")
        case .items100:
            return Image(systemName: "gauge.with.dots.needle.bottom.100percent")
        case .common1:
            return Image(systemName: "command")
        case .items1_000_000:
            return Image(systemName: "gauge.with.dots.needle.100percent")
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
        case .common1:
            return .commonItemsCreated(1)
        }
    }
    
    var bonusMessage: String? {
        switch self {
        case .items1:
            return nil
        case .items10:
            return "Research unlocked"
        case .items100:
            return "Sacrifices unlocked"
        case .common1:
            return "1% increased chance to find common items"
        case .items1_000_000:
            return "TODO"
        }
    }
    
}
