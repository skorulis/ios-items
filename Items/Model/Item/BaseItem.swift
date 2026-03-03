//Created by Alexander Skorulis on 10/2/2026.

import Foundation
import SwiftUI

/// Simple items that only have quantity
enum BaseItem: Hashable, Equatable, CaseIterable, Identifiable, Codable {
    
    // Junk
    case apple
    case rock
    case gear
    case potionFlask
    case copperFlorin
    case hourglass
    case lens
    case humanSkull
    
    
    // Common
    case silverFlorin
    
    // Good
    case goldFlorin
    
    var id: Self { self }
    
    var name: String {
        return String(describing: self).fromCaseName
    }
    
    var image: Image? {
        switch self {
        case .apple:
            return Asset.BaseItem.apple.swiftUIImage
        case .rock:
            return Asset.BaseItem.rock.swiftUIImage
        case .gear:
            return Asset.BaseItem.gear.swiftUIImage
        case .potionFlask:
            return Asset.BaseItem.flask.swiftUIImage
        case .copperFlorin:
            return Asset.BaseItem.copperCoin.swiftUIImage
        case .hourglass:
            return Asset.BaseItem.hourglass.swiftUIImage
        case .silverFlorin:
            return Asset.BaseItem.silverCoin.swiftUIImage
        case .goldFlorin:
            return Asset.BaseItem.goldCoin.swiftUIImage
        case .lens:
            return Asset.BaseItem.lens.swiftUIImage
        case .humanSkull:
            return Asset.BaseItem.humanSkull.swiftUIImage
        }
    }
    
    var quality: ItemQuality {
        switch self {
        case .apple, .rock, .hourglass, .copperFlorin, .gear, .potionFlask, .lens, .humanSkull:
            return .junk
        case .silverFlorin:
            return .common
        case .goldFlorin:
            return .good
        }
    }
    
    var essences: [Essence] {
        switch self {
        case .apple:
            return [.life]
        case .rock:
            return [.earth]
        case .gear:
            return [.technology]
        case .potionFlask:
            return [.magic]
        case .copperFlorin:
            return [.wealth]
        case .hourglass:
            return []
        case .silverFlorin:
            return [.wealth]
        case .goldFlorin:
            return [.wealth]
        case .lens:
            return [.light, .technology]
        case .humanSkull:
            return [.dark]
        }
    }
    
    var lore: [String] {
        switch self {
        case .apple:
            return ["Tastes good and keeps doctors away"]
        case .rock:
            return ["A stupid rock which may or may not repel tigers"]
        case .copperFlorin:
            return [
                "The base currency in the realm of Relicara"
            ]
        case .silverFlorin:
            return [
                "Worth 100 copper Florins"
            ]
        case .goldFlorin:
            return [
                "Worth 100 silver Florins"
            ]
        case .potionFlask:
            return [
                "A glass flask for mixing or storing potions",
                "The glass is embued with a subtle magic that prevents the contents from losing potency over time",
            ]
        case .lens:
            return [
                "A piece of glass shaped to focus light"
            ]
        case .humanSkull:
            return [
                "The skull of a long dead soldier. No telling which side they were on.",
                "The owner of the skull died in battle, it still radiates the desire for revenge"
            ]
        default:
            return []
        }
    }
}

