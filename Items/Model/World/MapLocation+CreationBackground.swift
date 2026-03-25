// Created by Cursor on 26/3/2026.

import Models
import SwiftUI

extension MapLocation {
    /// Full-bleed creation screen background when an asset exists.
    var creationBackgroundImage: Image? {
        switch self {
        case .vesprium:
            return Asset.MapLocation.vesprium.swiftUIImage
        case .semilTradingPost:
            return Asset.MapLocation.semilTradingPost.swiftUIImage
        case .palaceGardens:
            return Asset.MapLocation.palaceGardens.swiftUIImage
        case .university:
            return Asset.MapLocation.university.swiftUIImage
        case .crystalMine:
            return Asset.MapLocation.crystalMine.swiftUIImage
        }
    }
}
