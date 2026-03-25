//  Created by Alexander Skorulis on 25/3/2026.

import Foundation

// A Recipe to create items
public enum EquipmentRecipe: Codable, CaseIterable {

    case stoneDagger

    public var cost: [UpgradeCostItem] {
        switch self {
        case .stoneDagger:
            return [.init(item: .rock, quantity: 50)]
        }
    }

    public var quality: ItemQuality {
        material.quality
    }

    public var material: EquipmentMaterial {
        switch self {
        case .stoneDagger: return .stone
        }
    }

    public var kind: EquipmentKind {
        switch self {
        case .stoneDagger: return .dagger
        }
    }

    public func item(quality: ItemQuality) -> EquipmentInstance {
        return .init(kind: kind, material: material, quality: quality)
    }

    public var name: String {
        return "\(String(describing: self).fromCaseName) Recipe"
    }
}
