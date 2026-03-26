// Created by Alexander Skorulis on 25/3/2026.

import Foundation
import Models
import SwiftUI

extension EquipmentKind {
    var image: Image {
        switch self {
        case .shortSword:
            return Asset.Equipment.shortSword.swiftUIImage
        case .dagger:
            return Asset.Equipment.dagger.swiftUIImage
        }
    }
}
