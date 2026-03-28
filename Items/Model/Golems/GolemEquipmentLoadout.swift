// Created by Alexander Skorulis on 27/3/2026.

import Foundation
import Models

/// Equipment worn by a single golem (cosmetic); keys are body slots.
struct GolemEquipmentLoadout: Codable, Equatable {

    var slots: [EquipmentSlot: EquipmentInstance] = [:]

    func equipment(in slot: EquipmentSlot) -> EquipmentInstance? {
        slots[slot]
    }
    
    static func empty() -> Self {
        .init(slots: [:])
    }
}
