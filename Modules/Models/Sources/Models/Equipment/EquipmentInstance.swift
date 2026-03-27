//  Created by Alexander Skorulis on 25/3/2026.

import Foundation

/// A unique equippable gear piece built from compositional axes.
public struct EquipmentInstance: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public let kind: EquipmentKind
    public let material: EquipmentMaterial
    public let quality: ItemQuality

    public init(
        id: UUID = UUID(),
        kind: EquipmentKind,
        material: EquipmentMaterial,
        quality: ItemQuality,
    ) {
        self.id = id
        self.kind = kind
        self.material = material
        self.quality = quality
    }

    /// Composed display name, e.g. "Iron Short Sword", "Silver Dagger of Ice".
    public var displayName: String {
        "\(material.nameAdjective) \(kind.displayName)"
    }

    public var fullName: String {
        "\(quality.name)\(displayName)"
    }
    
    public var stats: EquipmentStats {
        return kind.baseStats.multiplied(value: quality.statMultiplier * material.statMultiplier)
    }

}
