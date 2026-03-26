// Created by Alexander Skorulis on 27/3/2026.

import Foundation

enum EnemyType: String, Codable, CaseIterable {
    case slime
    case raider
    case stoneBeast

    var maxHealth: Int {
        switch self {
        case .slime: 9
        case .raider: 12
        case .stoneBeast: 16
        }
    }

    var damagePerTick: Int {
        switch self {
        case .slime: 1
        case .raider: 2
        case .stoneBeast: 3
        }
    }

    var displayName: String {
        switch self {
        case .slime: "Slime"
        case .raider: "Raider"
        case .stoneBeast: "Stone Beast"
        }
    }
}
