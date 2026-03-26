//  Created by Alexander Skorulis on 25/3/2026.

import Foundation

// A Recipe to create items
public enum EquipmentRecipe: Codable, CaseIterable {

    case stoneDagger
    case crystalDagger
    case steelvineDagger
    case thunderscaleDagger
    case astralDagger

    public var quality: ItemQuality {
        material.quality
    }

    public var material: EquipmentMaterial {
        switch self {
        case .stoneDagger: return .stone
        case .crystalDagger: return .crystal
        case .steelvineDagger: return .steelvine
        case .thunderscaleDagger: return .thunderscale
        case .astralDagger: return .astral
        }
    }

    public var kind: EquipmentKind {
        switch self {
        case .stoneDagger, .crystalDagger, .steelvineDagger, .thunderscaleDagger, .astralDagger:
            return .dagger
        }
    }

    public func item(quality: ItemQuality) -> EquipmentInstance {
        return .init(kind: kind, material: material, quality: quality)
    }

    public var productName: String {
        String(describing: self).fromCaseName
    }

    public var name: String {
        return "\(productName) Recipe"
    }
}

// MARK: - Cost

extension EquipmentRecipe {
    
    public var cost: [UpgradeCostItem] {
        switch self {
        case .stoneDagger:
            return [.init(item: .rock, quantity: 50)]
        case .crystalDagger:
            return [
                .init(item: .quartzCrystal, quantity: 25),
                .init(item: .whetstone, quantity: 25),
            ]
        case .steelvineDagger:
            return [
                .init(item: .metalBloom, quantity: 25),
                .init(item: .giantThorn, quantity: 25),
            ]
        case .thunderscaleDagger:
            return [
                .init(item: .lightningStone, quantity: 25),
                .init(item: .metalBloom, quantity: 25),
                .init(item: .silverFlorin, quantity: 25),
            ]
        case .astralDagger:
            return [
                .init(item: .astralGem, quantity: 25),
                .init(item: .sunwellPhial, quantity: 25),
                .init(item: .anchorStone, quantity: 25),
            ]
        }
    }
}
