// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models

struct GolemInventory: Codable, Equatable {
    /// Owned count per golem type (missing keys mean zero).
    var counts: [GolemType: Int] = [:]

    func owned(_ type: GolemType) -> Int {
        counts[type] ?? 0
    }
}
