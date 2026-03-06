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
    case waxSeal

    // Common
    case whetstone
    case quartzCrystal
    case silverFlorin
    case steelArrowhead
    case book
    case merchantSigil
    case giantThorn
    case embuedChalk
    case metalBloom

    // Good
    case goldFlorin
    case jadeFigurine
    case portalShard
    case soulEmber
    case anchorStone
    case memorySeed
    case nullLantern

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
        case .quartzCrystal:
            return Asset.BaseItem.quartzCrystal.swiftUIImage
        case .steelArrowhead:
            return nil
        case .book:
            return nil
        case .jadeFigurine:
            return nil
        case .merchantSigil:
            return nil
        case .giantThorn:
            return nil
        case .portalShard:
            return nil
        case .whetstone:
            return nil
        case .embuedChalk:
            return nil
        case .metalBloom:
            return nil
        case .soulEmber:
            return nil
        case .anchorStone:
            return nil
        case .waxSeal:
            return nil
        case .memorySeed:
            return nil
        case .nullLantern:
            return nil
        }
    }
    
    var quality: ItemQuality {
        switch self {
        case .apple, .rock, .hourglass, .copperFlorin, .gear, .potionFlask, .lens, .humanSkull, .waxSeal:
            return .junk
        case .quartzCrystal, .silverFlorin, .steelArrowhead, .book, .merchantSigil, .giantThorn, .embuedChalk, .whetstone, .metalBloom:
            return .common
        case .goldFlorin, .jadeFigurine, .portalShard, .soulEmber, .anchorStone, .memorySeed, .nullLantern:
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
        case .quartzCrystal:
            return [.earth, .light]
        case .steelArrowhead:
            return [.dark, .technology]
        case .book:
            return [.light, .knowledge]
        case .jadeFigurine:
            return [.earth, .wealth]
        case .merchantSigil:
            return [.wealth, .magic]
        case .giantThorn:
            return [.life, .earth]
        case .portalShard:
            return [.magic, .light]
        case .whetstone:
            return [.earth, .technology]
        case .embuedChalk:
            return [.knowledge, .magic]
        case .metalBloom:
            return [.life, .technology]
        case .soulEmber:
            return [.dark, .magic]
        case .anchorStone:
            return [.earth, .magic]
        case .waxSeal:
            return [.knowledge]
        case .memorySeed:
            return [.life, .knowledge]
        case .nullLantern:
            return [.dark, .technology]
        }
    }
    
    var lore: [String] {
        switch self {
        case .apple:
            return ["Tastes good and keeps doctors away"]
        case .rock:
            return [
                    "Looks like an ordinary rock",
                    "Even this simple rock has a connection back to its home dimension"
            ]
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
        case .quartzCrystal:
            return [
                "A clear crystal that catches and bends light",
                "Formed deep in the earth, it holds both stone and radiance"
            ]
        case .steelArrowhead:
            return [
                "A plain but well constructed broadhead arrowhead.",
                "The marks on the side show evidence of the forging"
            ]
        case .book:
            return [
                "Bound pages of paper in an unknown language",
                "The words mean nothing to you, but perhaps the portal can understand them"
            ]
        case .jadeFigurine:
            return [
                "Carved from green jade; it's a humanoid figure but it's impossible to tell what the subject was",
                "There are a large number of the same figurine, perhaps this is a religions relic.",
            ]
        case .merchantSigil:
            return [
                "A hexagon made of an unknown material with a different logo on each side",
                "It marks a trade pact made between 2 merchants"
            ]
        case .giantThorn:
            return [
                "Shaped like a rose thorn only over 10cm long with a iridescent coloring",
                "The thorn is harder than steel, this could easily be used as a weapon"
            ]
        case .portalShard:
            return [
                "Crystallized energy from a closed or unstable portal.",
                "It seems the people of this dimension also had access to portals."
            ]
        case .whetstone:
            return [
                "A flat stone for sharpening blades; every smith and soldier carries one.",
                "Keeping an edge is the difference between a clean cut and a messy one.",
            ]
        case .embuedChalk:
            return [
                "It looks like regular chalk but it's warm to the touch. Using it to draw leaves a line that glows faintly.",
                "Can be used to create wards or runes.",
            ]
        case .metalBloom:
            return [
                "A flower with fine metal lines running through its petals and stem. Part bloom, part vein of ore.",
                "It's hard to say whether the metal grows naturally or if the plant has been deliberately altered.",
                "The petals don't wilt no matter how long since it has been picked",
            ]
        case .soulEmber:
            return [
                "A dull ember that never goes out. Uncomfortable to hold.",
                "Said to contain the last spark of a dying persons soul. Used as storage so the soul can be consumed at a later time"
            ]
        case .anchorStone:
            return [
                "A small, smooth stone with a hole through the center.",
                "Used to keep a steady position when dealing with portal forces",
            ]
        case .waxSeal:
            return [
                "A used seal from a letter or document. The message is gone; only the stamped wax remains.",
            ]
        case .memorySeed:
            return [
                "A seed that holds a memory, locked inside until it is grown.",
                "Those who nurture it to bloom are said to receive the memory as a vision.",
                "Once the plant has grown more seeds can be harvested to be either sold or grown again to revist the memory",
            ]
        case .nullLantern:
            return [
                "A lantern whose workings erase light instead of casting it, swallowing reflections and magical glows in a small radius.",
                "Can be used to hide runes and wards from those trying to search for magical items."
            ]
        default:
            return []
        }
    }
}

