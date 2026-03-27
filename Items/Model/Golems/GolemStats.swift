// Created by Alexander Skorulis on 27/3/2026.

import Foundation

/// Combat and movement parameters used while a golem mission is running.
struct GolemStats: Codable, Equatable {
    var health: Int
    var attack: Int
    var defence: Int
    var speed: Double

    static let basic = GolemStats(
        health: 60,
        attack: 4,
        defence: 0,
        speed: 1
    )
}
