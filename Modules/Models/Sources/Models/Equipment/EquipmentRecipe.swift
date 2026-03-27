//  Created by Alexander Skorulis on 25/3/2026.

import Foundation

public struct EquipmentRecipe: Codable, Equatable, Sendable, Hashable {
    public let kind: EquipmentKind
    public let material: EquipmentMaterial
    public let cost: [UpgradeCostItem]
    
    public func item(quality: ItemQuality) -> EquipmentInstance {
        return .init(kind: kind, material: material, quality: quality)
    }
    
    public var productName: String {
        return "\(material.nameAdjective) \(kind.displayName)"
    }

    public var name: String {
        return "\(productName) Recipe"
    }
    
    public var quality: ItemQuality { material.quality }
    
}

extension EquipmentRecipe {
    public static var allCases: [EquipmentRecipe] {
        let daggers = EquipmentMaterial.weaponMaterials.map {
            EquipmentRecipe(kind: .dagger, material: $0, cost: bladeWeaponCost(material: $0))
        }
        
        return [
            daggers
        ]
        .flatMap { $0 }
    }
}

// MARK: - Cost

extension EquipmentRecipe {
    static func bladeWeaponCost(material: EquipmentMaterial) -> [UpgradeCostItem] {
        switch material {
        case .stone:
            return [.init(item: .rock, quantity: 50)]
        case .crystal:
            return [
                .init(item: .quartzCrystal, quantity: 25),
                .init(item: .whetstone, quantity: 25),
            ]
        case .steelvine:
            return [
                .init(item: .metalBloom, quantity: 25),
                .init(item: .giantThorn, quantity: 25),
            ]
        case .thunderscale:
            return [
                .init(item: .lightningStone, quantity: 25),
                .init(item: .metalBloom, quantity: 25),
                .init(item: .silverFlorin, quantity: 25),
            ]
        case .astral:
            return [
                .init(item: .astralGem, quantity: 25),
                .init(item: .sunwellPhial, quantity: 25),
                .init(item: .anchorStone, quantity: 25),
            ]
        default:
            fatalError("Unexpected materail for ")
        }
    }
}
