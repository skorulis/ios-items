//  Created by Alexander Skorulis on 25/3/2026.

import Foundation
import SwiftUI

public enum EquipmentMaterial: String, Codable, CaseIterable, Hashable, Identifiable, Sendable {
    case stone
    case crystal
    case steelvine
    case astral

    public var id: Self { self }

    /// Leading adjective for composed name
    public var nameAdjective: String {
        String(describing: self).fromCaseName
    }

    /// Quality tier this material corresponds to
    public var quality: ItemQuality {
        switch self {
        case .stone:
            return .junk
        case .crystal:
            return .common
        case .steelvine:
            return .good
        case .astral:
            return .exceptional
        }
    }

    /// UI color for this material (derived from its quality tier).
    public var color: Color {
        switch self {
        case .stone:
            return .gray
        case .crystal:
            return .yellow
        case .steelvine:
            return .green
        case .astral:
            return .orange
        }
    }
}
