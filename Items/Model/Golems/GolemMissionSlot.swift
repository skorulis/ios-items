// Created by Alexander Skorulis on 24/3/2026.

import Foundation
import Models

struct GolemMissionSlot: Codable {

    enum Phase: String, Codable {
        case setup
        case running
        case complete
    }

    static let missionMaxHealth: Int = 60
    static let maxEnemies: Int = 3
    static let enemyAttackRangeMeters: Double = 0.5
    static let enemySpawnDistanceMeters: Double = 6.0
    static let golemMetersPerTick: Double = 1.0
    static let enemyMetersPerTick: Double = 1.0

    var phase: Phase
    var location: MapLocation

    private(set) var startedAt: Date
    var remainingHealth: Int?
    var gainedItems: [Ingredient: Int]
    var enemiesDefeated: Int = 0
    var exploringDistanceMeters: Int = 0

    struct Enemy: Codable, Identifiable, Equatable {
        var id: UUID = UUID()
        var type: EnemyType
        var maxHealth: Int
        var remainingHealth: Int
        /// Distance between enemy and golem.
        ///
        /// Values are updated by `GolemMissionService`. Render layer can interpolate visually.
        var distanceToGolemMeters: Double

        init(
            id: UUID = UUID(),
            type: EnemyType,
            maxHealth: Int,
            remainingHealth: Int,
            distanceToGolemMeters: Double
        ) {
            self.id = id
            self.type = type
            self.maxHealth = maxHealth
            self.remainingHealth = remainingHealth
            self.distanceToGolemMeters = distanceToGolemMeters
        }

        var isDead: Bool { remainingHealth <= 0 }
        var remainingFraction: Double {
            guard maxHealth > 0 else { return 0 }
            return min(1, max(0, Double(remainingHealth) / Double(maxHealth)))
        }
    }

    /// Enemies currently on the lane (up to `maxEnemies`).
    var enemies: [Enemy] = []

    /// Next wall-time when a new enemy may spawn (if there is free capacity).
    var nextEnemySpawnAt: Date?

    /// Last wall-time when the simulation advanced.
    var lastSimulatedAt: Date = Date()

    mutating func scheduleNextEnemySpawn(from now: Date) {
        // 1..3 second jitter around a base interval, feels "random but not chaotic".
        let interval: TimeInterval = Double.random(in: 1.5 ... 3.5)
        nextEnemySpawnAt = now.addingTimeInterval(interval)
    }

    mutating func start(date: Date) {
        self.phase = .running
        self.startedAt = date
        self.remainingHealth = Self.missionMaxHealth
        self.enemies = []
        self.nextEnemySpawnAt = date.addingTimeInterval(Double.random(in: 1.0 ... 2.5))
        self.lastSimulatedAt = date
        self.gainedItems = [:]
        self.enemiesDefeated = 0
        self.exploringDistanceMeters = 0
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
        enemiesDefeated: Int = 0,
        exploringDistanceMeters: Int = 0,
        enemies: [Enemy] = [],
        nextEnemySpawnAt: Date? = nil,
        lastSimulatedAt: Date = Date()
    ) {
        self.phase = phase
        self.location = location
        self.startedAt = Date()
        self.remainingHealth = remainingHealth
        self.gainedItems = [:]
        self.enemiesDefeated = enemiesDefeated
        self.exploringDistanceMeters = exploringDistanceMeters
        self.enemies = enemies
        self.nextEnemySpawnAt = nextEnemySpawnAt
        self.lastSimulatedAt = lastSimulatedAt
    }

    static func empty() -> GolemMissionSlot {
        GolemMissionSlot(
            phase: .setup,
            location: .vesprium,
            remainingHealth: nil
        )
    }
}
