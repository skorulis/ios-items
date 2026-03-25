// Created by Alexander Skorulis on 24/3/2026.

import Foundation
import Models

struct GolemMissionSlot: Codable {

    enum Phase: String, Codable {
        case setup
        case running
        case complete
    }

    enum AccidentType: String, Codable, CaseIterable {
        case toeStub
        case tripped
        case fellInAHole

        var damageRange: ClosedRange<Int> {
            switch self {
            case .toeStub: 1 ... 2
            case .tripped: 2 ... 4
            case .fellInAHole: 4 ... 7
            }
        }

        func activityLogMessage(damage: Int) -> String {
            switch self {
            case .toeStub:
                return "Stubbed their toe for \(damage) damage."
            case .tripped:
                return "Tripped on a rock for \(damage) damage."
            case .fellInAHole:
                return "Fell in a hole for \(damage) damage."
            }
        }
    }

    /// Persisted mission activity while running.
    enum MissionActivityState: Codable {
        case exploring
        case gathering
        case accident(AccidentType)
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
    var gainedItems: [Ingredient: Int]
    /// Timeline of notable mission events (started, activity changes, gathering results, completion).
    var activityLog: [GolemMissionLogEntry]
    /// Meters travelled while in the exploring activity (this mission run).
    var exploringDistanceMeters: Int = 0

    mutating func setActivity(state: MissionActivityState, date: Date) {
        self.activityStartDate = date
        self.missionActivityState = state
    }

    mutating func appendActivityLog(_ message: String, date: Date) {
        activityLog.append(GolemMissionLogEntry(date: date, message: message))
    }

    mutating func start(date: Date, initialHealth: Int) {
        self.phase = .running
        self.startedAt = date
        self.remainingHealth = initialHealth
        self.missionActivityState = .exploring
        self.activityStartDate = date
        self.gainedItems = [:]
        self.activityLog = []
        self.exploringDistanceMeters = 0
        appendActivityLog("Mission started.", date: date)
    }

    mutating func add(results: [MakeItemResult]) {
        for res in results {
            switch res {
            case let .base(baseItem, count):
                let oldCount = gainedItems[baseItem, default: 0]
                gainedItems[baseItem] = oldCount + count
            case .artifact, .recipe:
                print("Unexpected. Golems should not find artifacts or recipes")
            }
        }
    }

    mutating func takeDamage(_ damage: Int) {
        let health = remainingHealth ?? 0
        remainingHealth = max(0, health - damage)
    }

    init(
        phase: Phase,
        golemType: GolemType?,
        location: MapLocation?,
        remainingHealth: Int? = nil,
        missionActivityState: MissionActivityState = .exploring,
        activityLog: [GolemMissionLogEntry] = [],
        exploringDistanceMeters: Int = 0,
    ) {
        self.phase = phase
        self.golemType = golemType
        self.location = location
        self.startedAt = Date()
        self.activityStartDate = Date()
        self.remainingHealth = remainingHealth
        self.missionActivityState = missionActivityState
        self.gainedItems = [:]
        self.activityLog = activityLog
        self.exploringDistanceMeters = exploringDistanceMeters
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

struct GolemMissionLogEntry: Codable, Equatable, Hashable {
    var date: Date
    var message: String
}
