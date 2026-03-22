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

struct GolemMissionSlot: Codable {

    enum Phase: String, Codable {
        case setup
        case running
        case complete
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
    /// Health remaining while running or zero when complete; nil in setup.
    var remainingHealth: Int?
    // The last time the activity changed
    private(set) var activityStartDate: Date
    private(set) var missionActivityState: MissionActivityState
    var gainedItems: [BaseItem: Int]

    mutating func setActivity(state: MissionActivityState, date: Date) {
        self.activityStartDate = date
        self.missionActivityState = state
    }

    mutating func start(date: Date, initialHealth: Int) {
        self.phase = .running
        self.startedAt = date
        self.remainingHealth = initialHealth
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
        remainingHealth: Int? = nil,
        missionActivityState: MissionActivityState = .exploring,
    ) {
        self.phase = phase
        self.golemType = golemType
        self.location = location
        self.startedAt = Date()
        self.activityStartDate = Date()
        self.remainingHealth = remainingHealth
        self.missionActivityState = missionActivityState
        self.gainedItems = [:]
    }

    static func empty() -> GolemMissionSlot {
        GolemMissionSlot(
            phase: .setup,
            golemType: nil,
            location: nil,
            remainingHealth: nil
        )
    }
}
