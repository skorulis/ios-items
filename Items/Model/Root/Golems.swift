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
    static let defaultDuration: TimeInterval = 60
}

struct GolemMissionSlot: Codable {

    enum Phase: String, Codable {
        case setup
        case running
    }

    enum MissionActivityState: String, Codable {
        case exploring
        case gathering
    }

    var phase: Phase
    var golemType: GolemType?
    var location: MapLocation?

    // When the mission started (only relevant for the runnin phase)
    private(set) var startedAt: Date
    var duration: TimeInterval?
    // The last time the activity changed
    private(set) var activityStartDate: Date
    private(set) var missionActivityState: MissionActivityState
    var gainedItems: [BaseItem: Int]

    mutating func setActivity(state: MissionActivityState, date: Date) {
        self.activityStartDate = date
        self.missionActivityState = state
    }

    mutating func start(date: Date) {
        self.phase = .running
        self.startedAt = date
        self.missionActivityState = .exploring
        self.activityStartDate = date
        self.gainedItems = [:]
    }

    mutating func add(results: [MakeItemResult]) {
        for res in results {
            switch res {
            case let .base(baseItem, count):
                let oldCount = gainedItems[baseItem, default: 0]
                gainedItems[baseItem] = oldCount + count
            case .artifact:
                print("Unexpected. Golems should not find artifacts")
            }
        }
    }

    init(
        phase: Phase,
        golemType: GolemType?,
        location: MapLocation?,
        duration: TimeInterval?,
        missionActivityState: MissionActivityState = .exploring,
    ) {
        self.phase = phase
        self.golemType = golemType
        self.location = location
        self.startedAt = Date()
        self.activityStartDate = Date()
        self.duration = duration
        self.missionActivityState = missionActivityState
        self.gainedItems = [:]
    }

    static func empty() -> GolemMissionSlot {
        GolemMissionSlot(
            phase: .setup,
            golemType: nil,
            location: nil,
            duration: nil
        )
    }
}
