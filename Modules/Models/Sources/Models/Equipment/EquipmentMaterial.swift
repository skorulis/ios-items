//  Created by Alexander Skorulis on 25/3/2026.

import Foundation
import SwiftUI

public enum EquipmentMaterial: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case stone
    case iron
    case leather
    case silver

    public var id: Self { self }

    /// Leading adjective for composed names (e.g. "Iron", "Leather").
    public var nameAdjective: String {
        String(describing: self).fromCaseName
    }

    public var quality: ItemQuality {
        switch self {
        case .stone:
            return .junk
        case .iron:
            return .common
        case .leather:
            return .common
        case .silver:
            return .good
        }
    }

    /// UI color for this material (derived from its quality tier).
    public var color: Color {
        switch self {
        case .stone:
            return .orange
        case .iron:
            return .gray
        case .leather:
            return .brown
        case .silver:
            return .cyan
        }
    }
}
