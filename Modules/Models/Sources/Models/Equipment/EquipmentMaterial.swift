//  Created by Alexander Skorulis on 25/3/2026.

import Foundation
import SwiftUI

public enum EquipmentMaterial: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case stone
    case wovenReed
    case crystal
    case steelvine
    case thunderscale
    case astral

    public var id: Self { self }

    /// Leading adjective for composed name
    public var nameAdjective: String {
        String(describing: self).fromCaseName
    }
    
    static var weaponMaterials: [EquipmentMaterial] {
        [.stone, .crystal, .steelvine, .thunderscale, .astral]
    }
    
    static var armorMaterials: [EquipmentMaterial] {
        [.wovenReed, .crystal, .steelvine, .thunderscale, .astral]
    }

    /// Quality tier this material corresponds to
    public var quality: ItemQuality {
        switch self {
        case .stone, .wovenReed:
            return .junk
        case .crystal:
            return .common
        case .steelvine:
            return .good
        case .thunderscale:
            return .rare
        case .astral:
            return .exceptional
        }
    }

    /// UI color for this material (derived from its quality tier).
    public var color: Color {
        switch self {
        case .stone:
            return .gray
        case .wovenReed:
            return .brown
        case .crystal:
            return .yellow
        case .steelvine:
            return .green
        case .thunderscale:
            return .blue
        case .astral:
            return .orange
        }
    }
}
