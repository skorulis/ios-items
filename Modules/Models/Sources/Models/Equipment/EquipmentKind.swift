//  Created by Alexander Skorulis on 25/3/2026.

import Foundation

/// Base silhouette for compositional gear icons (one asset per case).
public enum EquipmentKind: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case shortSword
    case dagger

    public var id: Self { self }

    /// Human-readable noun for display names (e.g. "Short Sword").
    public var displayName: String {
        String(describing: self).fromCaseName
    }

    public var slot: EquipmentSlot {
        switch self {
        case .shortSword, .dagger:
            return .mainHand
        }
    }

    public var baseStats: EquipmentStats {
        switch self {
        case .shortSword:
            return EquipmentStats(attack: 1)
        case .dagger:
            return EquipmentStats(attack: 1.5)
        }
    }
}
