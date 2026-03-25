// Created by Alexander Skorulis on 26/3/2026.

import Foundation
import Models

extension EquipmentInstance {

    var image: LayeredIcon {
        return .init(
            main: self.kind.image,
            tintColor: self.material.color,
        )
    }
}
