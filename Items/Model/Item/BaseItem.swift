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
    
    case woodenChair
    case cactus
    case vinylRecord
    case snowGlobe
    case umbrella
    case compass
    
    
    // Common
    case silverFlorin
    
    // Good
    case goldFlorin
    
    var id: Self { self }
    
    var name: String {
        return String(describing: self)
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
        default:
            return nil
        }
    }
    
    var acronym: String {
        switch self {
        case .apple: return "AP"
        case .rock: return "RK"
        case .gear: return "GE"
        case .potionFlask: return "PF"
        case .copperFlorin: return "CF"
        case .woodenChair: return "WC"
        case .cactus: return "CA"
        case .vinylRecord: return "VR"
        case .snowGlobe: return "SG"
        case .umbrella: return "UM"
        case .hourglass: return "HG"
        case .compass: return "CP"
        case .silverFlorin: return "SF"
        case .goldFlorin: return "GF"
        }
    }
    
    var quality: ItemQuality {
        switch self {
        case .apple, .rock, .woodenChair, .cactus, .vinylRecord, .snowGlobe, .umbrella, .hourglass, .compass, .copperFlorin, .gear, .potionFlask:
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
        case .woodenChair:
            return [.life]
        case .cactus:
            return []
        case .vinylRecord:
            return [.technology]
        case .snowGlobe:
            return []
        case .umbrella:
            return []
        case .hourglass:
            return []
        case .compass:
            return []
        case .silverFlorin:
            return [.wealth]
        case .goldFlorin:
            return [.wealth]
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
        default:
            return []
        }
    }
}

