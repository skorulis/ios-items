//  Created by Alexander Skorulis on 27/3/2026.

import Foundation

/// Bonus stats granted by an equipment piece.
public struct EquipmentStats: Codable, Equatable, Hashable, Sendable {
    public let attack: Double
    public let defence: Double

    public init(
        attack: Double = 0,
        defence: Double = 0
    ) {
        self.attack = attack
        self.defence = defence
    }
    
    public func multiplied(value: Double) -> EquipmentStats {
        return EquipmentStats(
            attack: attack * value,
            defence: defence * value,
        )
    }
}
