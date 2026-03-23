// Created by Alexander Skorulis on 11/2/2026.

import Foundation

struct Statistics: Codable {
    var itemsCreated: Int64 = 0
    var multipleItemCreations: Int64 = 0
    var itemsSacrificed: Int64 = 0
    var tradesCompleted: Int64 = 0
    /// Total meters traveled by golems on completed missions (all locations).
    var golemDistanceTraveledMeters: Int64 = 0
}
