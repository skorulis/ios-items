// Created by Alexander Skorulis on 27/3/2026.

import Foundation
import Models

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

extension EnemyType {

    /// Roll a simple base-item drop for the golem mission loot bag.
    ///
    /// Kept deterministic-ish by enemy type so the drops feel themed.
    func rollDrop() -> Ingredient {
        // Small chance for slightly better drops on stronger enemies.
        let roll = Int.random(in: 0..<100)
        switch self {
        case .slime:
            // "Goo + life/chaos" vibe.
            return [Ingredient.apple, .potionFlask, .embuedChalk].randomElement() ?? .apple

        case .raider:
            if roll < 10 { return .silverFlorin }
            return [Ingredient.gear, .whetstone, .copperFlorin, .mapFragment].randomElement() ?? .gear

        case .stoneBeast:
            if roll < 6 { return .anchorStone }
            if roll < 18 { return .quartzCrystal }
            return [Ingredient.rock, .whetstone, .hourglass].randomElement() ?? .rock
        }
    }
}
