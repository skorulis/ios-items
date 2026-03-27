// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models

struct Golems: Codable {

    /// Mission setup
    var slots: [Int: GolemMissionSlot] = [:]

    /// Cosmetic gear per golem mission slot index.
    var equipmentByGolem: [Int: GolemEquipmentLoadout] = [:]

}
