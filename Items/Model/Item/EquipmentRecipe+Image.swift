// Created by Alex Skorulis on 26/3/2026.

import Foundation
import Models

extension EquipmentRecipe {

    var icon: LayeredIcon {
        return self.item(quality: material.quality).image
    }
}
