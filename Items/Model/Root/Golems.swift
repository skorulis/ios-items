// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models

struct Golems: Codable {

    static let slotCount = 1

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

/// Default mission length (seconds); tune in one place.
enum GolemMissionTiming {
    static let defaultDuration: TimeInterval = 300
}

struct GolemMissionSlot: Codable, Equatable {

    enum Phase: String, Codable {
        case setup
        case running
    }

    var phase: Phase
    var golemType: GolemType?
    var location: MapLocation?
    var startedAt: Date?
    var duration: TimeInterval?

    static func empty() -> GolemMissionSlot {
        GolemMissionSlot(
            phase: .setup,
            golemType: nil,
            location: nil,
            startedAt: nil,
            duration: nil
        )
    }
}
