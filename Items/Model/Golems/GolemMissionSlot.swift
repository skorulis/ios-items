// Created by Alexander Skorulis on 24/3/2026.

import Foundation
import Models

struct GolemMissionSlot: Codable {

    enum Phase: String, Codable {
        case setup
        case running
        case complete
    }

    /// Persisted mission activity while running.
    enum MissionActivityState: Codable {
        case exploring
        case approachingEnemy(
            type: EnemyType,
            enemyMaxHealth: Int,
            enemyRemainingHealth: Int,
            approachStartedAt: Date,
            contactAt: Date
        )
        case combat(
            type: EnemyType,
            enemyMaxHealth: Int,
            enemyRemainingHealth: Int
        )
    }

    static let missionMaxHealth: Int = 60

    var phase: Phase
    var location: MapLocation

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

    mutating func start(date: Date) {
        self.phase = .running
        self.startedAt = date
        self.remainingHealth = Self.missionMaxHealth
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
        location: MapLocation = .vesprium,
        remainingHealth: Int? = nil,
        missionActivityState: MissionActivityState = .exploring,
        activityLog: [GolemMissionLogEntry] = [],
        exploringDistanceMeters: Int = 0,
    ) {
        self.phase = phase
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
            location: .vesprium,
            remainingHealth: nil
        )
    }
}

struct GolemMissionLogEntry: Codable, Equatable, Hashable {
    var date: Date
    var message: String
}
