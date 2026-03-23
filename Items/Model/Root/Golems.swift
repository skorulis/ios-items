// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models

struct Golems: Codable {

    /// Mission slots before portal upgrades (`golemMissionSlots` bonuses add to this).
    static let baseMissionSlotCount = 1

    /// Owned count per golem type (missing keys mean zero).
    var inventory: [GolemType: Int] = [:]

    /// Mission setup
    var slots: [Int: GolemMissionSlot] = [:]

    func owned(_ type: GolemType) -> Int {
        inventory[type] ?? 0
    }

    mutating func addOne(_ type: GolemType) {
        inventory[type, default: 0] += 1
    }

    @discardableResult
    mutating func removeOne(_ type: GolemType) -> Bool {
        guard inventory[type, default: 0] > 0 else { return false }
        inventory[type, default: 0] -= 1
        return true
    }

}
