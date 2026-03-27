// Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Simple items that only have quantity
public enum Ingredient: String, Hashable, Equatable, CaseIterable, Identifiable, Codable, Sendable {
    // Junk
    case copperFlorin
    case apple
    case rock
    case gear
    case potionFlask
    case hourglass
    case lens
    case humanSkull // TODO: Replace this item

    // Common
    case silverFlorin
    case whetstone
    case quartzCrystal
    case book
    case merchantSigil
    case giantThorn
    case embuedChalk
    case mapFragment

    // Good
    case goldFlorin
    case jadeFigurine
    case portalShard
    case soulEmber
    case anchorStone
    case memorySeed
    case metalBloom
    case cipherRibbon

    // Rare
    case platinumFlorin
    case sunwellPhial
    case lightningStone
    case abyssalGeode
    case entangledSaltLattice
    case dreamSporeMushroom

    // Exceptional
    case astralGem

    public var id: Self { self }

    public var name: String {
        return String(describing: self).fromCaseName
    }

    public var quality: ItemQuality {
        switch self {
        case .apple, .rock, .hourglass, .copperFlorin, .gear, .potionFlask, .lens, .humanSkull:
            return .junk
        case .quartzCrystal, .silverFlorin, .book, .merchantSigil, .giantThorn, .embuedChalk, .whetstone, .mapFragment:
            return .common
        case .goldFlorin, .jadeFigurine, .portalShard, .soulEmber, .anchorStone, .memorySeed, .metalBloom, .cipherRibbon:
            return .good
        case .platinumFlorin, .sunwellPhial, .lightningStone, .abyssalGeode, .entangledSaltLattice, .dreamSporeMushroom:
            return .rare
        case .astralGem:
            return .exceptional
        }
    }

    /// Numeric rarity tier for item generation or display; higher means rarer.
    /// Default is 1; override per case when an item should be treated as more (or less) rare.
    public var rarity: Double {
        switch self {
        case .copperFlorin:
            return 2.0
        case .silverFlorin:
            return 1.5
        case .goldFlorin:
            return 1.25
        case .platinumFlorin:
            return 1.1
        default:
            return 1.0
        }
    }

    public var essences: [Essence] {
        switch self {
            // Junk
        case .apple:
            return [.life]
        case .rock:
            return [.earth]
        case .gear:
            return [.order]
        case .potionFlask:
            return [.chaos]
        case .copperFlorin:
            return [.covenant]
        case .hourglass:
            return [.mind]
        case .lens:
            return [.light]
        case .humanSkull:
            return [.dark]

            // Common
        case .silverFlorin:
            return [.covenant, .order]
        case .quartzCrystal:
            return [.earth, .light]
        case .book:
            return [.light, .mind]
        case .merchantSigil:
            return [.covenant, .order]
        case .giantThorn:
            return [.life, .chaos]
        case .embuedChalk:
            return [.mind, .chaos]
        case .mapFragment:
            return [.mind, .earth]
        case .whetstone:
            return [.order, .dark]

            // Good
        case .goldFlorin:
            return [.covenant]
        case .cipherRibbon:
            return [.dark, .mind]
        case .jadeFigurine:
            return [.earth, .covenant]
        case .portalShard:
            return [.chaos, .light]
        case .metalBloom:
            return [.life, .order, .chaos]
        case .soulEmber:
            return [.dark, .chaos]
        case .anchorStone:
            return [.earth, .chaos]
        case .memorySeed:
            return [.life, .mind]
        case .dreamSporeMushroom:
            return [.mind, .life, .dark]

            // Rare
        case .platinumFlorin:
            return [.covenant, .order]
        case .sunwellPhial:
            return [.light, .life]
        case .lightningStone:
            return [.light, .order, .earth]
        case .abyssalGeode:
            return [.dark, .earth, .chaos]
        case .entangledSaltLattice:
            return [.earth, .chaos, .mind]

            // Exceptional
        case .astralGem:
            return [.covenant, .chaos, .light]
        }
    }

    /// Whether this item should only appear in specific locations on the world map.
    /// When `true`, item generation outside `LocationDetails.uniqueItems` should not include this item.
    public var locationSpecific: Bool {
        switch self {
        case .merchantSigil, .quartzCrystal:
            return true
        default:
            return false
        }
    }

    public static var locationSpecificItems: [Ingredient] {
        allCases.filter { $0.locationSpecific }
    }

    public var lore: [String] {
        switch self {
        case .apple:
            return ["Tastes good and keeps doctors away"]
        case .rock:
            return [
                "Looks like an ordinary rock",
                "Even this simple rock has a connection back to its home dimension",
            ]
        case .copperFlorin:
            return [
                "The base unit of currency in the realm of Vesprium",
                "Coins are the primary item used to purchase portal upgrades",
            ]
        case .gear:
            return [
                "A mechanical gear that forms part of a machine"
            ]
        case .hourglass:
            return [
                "A simple means of keeping track of time"
            ]
        case .silverFlorin:
            return [
                "Worth 100 copper Florins"
            ]
        case .goldFlorin:
            return [
                "Worth 100 silver Florins"
            ]
        case .platinumFlorin:
            return [
                "Worth 100 gold Florins",
                "Minted in tiny batches for the largest guild contracts and cross-city levies.",
            ]
        case .astralGem:
            return [
                "A gem made of condensed astral light.",
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
                "The owner of the skull died in battle, it still radiates the desire for revenge",
            ]
        case .quartzCrystal:
            return [
                "A clear crystal that catches and bends light",
                "Formed deep in the earth, it holds both stone and radiance",
            ]
        case .book:
            return [
                "Bound pages of paper in an unknown language",
                "The words mean nothing to you, but perhaps the portal can understand them",
            ]
        case .jadeFigurine:
            return [
                "Carved from green jade; it's a humanoid figure but it's impossible to tell what the subject was",
                "There are a large number of the same figurine, perhaps this is a religions relic.",
            ]
        case .merchantSigil:
            return [
                "A hexagon made of an unknown material with a different logo on each side",
                "It marks a trade pact made between 2 merchants",
            ]
        case .giantThorn:
            return [
                "Shaped like a rose thorn only over 10cm long with a iridescent coloring",
                "The thorn is harder than steel, this could easily be used as a weapon",
            ]
        case .portalShard:
            return [
                "Crystallized energy from a closed or unstable portal.",
                "It seems the people of this dimension also had access to portals.",
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
        case .mapFragment:
            return [
                "A torn piece of parchment or vellum showing part of a landscape or route.",
                "Several fragments from the same map could be pieced together to reveal a path or location.",
            ]
        case .cipherRibbon:
            return [
                "A narrow ribbon woven with faint sigils. When tied around a document, the writing refuses to be read until the owner speaks the binding word.",
                "Without the codeword, pages show only as a blur.",
            ]
        case .dreamSporeMushroom:
            return [
                "A black and white mushroom that when squeezed emits pale spores",
                "If the spores are breathed in while sleeping, scraps of that sleeper's dreams will begin to show above them as they slumber.",
            ]
        case .soulEmber:
            return [
                "A dull ember that never goes out. Uncomfortable to hold.",
                "Said to contain the last spark of a dying persons soul. Used as storage so the soul can be consumed at a later time",
            ]
        case .anchorStone:
            return [
                "A small, smooth stone with a hole through the center.",
                "Used to keep a steady position when dealing with portal forces",
            ]
        case .memorySeed:
            return [
                "A seed that holds a memory, locked inside until it is grown.",
                "Those who nurture it to bloom are said to receive the memory as a vision.",
                "Once the plant has grown more seeds can be harvested to be either sold or grown again to revist the memory",
            ]
        case .sunwellPhial:
            return [
                "A sealed vial of liquid light drawn from a long lost spring.",
                "A few drops can revive withered plants make them grow.",
            ]
        case .lightningStone:
            return [
                "A dense stone threaded with bright veins; storm has been caught and held inside.",
                "Artificers can tap it like a battery or forge it into weapons",
            ]
        case .abyssalGeode:
            return [
                "A hollow stone lined with black crystals that seem to shift when you're not looking directly at them.",
                "Formed in the deepest seams of the world, the level of pressure and exposure to chaos has created a stone with impossible internal angles.",
            ]
        case .entangledSaltLattice:
            return [
                "Salt crystals from a flooded mine, grown in matched pairs: split one from its twin and each half still remembers the other.",
                "Trace embued chalk across one lattice and the message appears on the other briefly before fading",
            ]
        }
    }
}
