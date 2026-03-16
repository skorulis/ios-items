// Created by Cursor on 16/3/2026.
//
// Root model for world map location state stored in MainStore.

import Foundation
import Models

struct MapLocations: Codable {

    /// Locations that have been unlocked by the player.
    var unlocked: Set<MapLocation> = [.vesprium]

    var selected: MapLocation = .vesprium

    /// Number of times items have been pulled from each location.
    var itemPullCount: [MapLocation: Int] = [:]

    /// Whether a given location is unlocked.
    func isUnlocked(_ location: MapLocation) -> Bool {
        unlocked.contains(location)
    }

    /// Number of times items have been pulled from the given location.
    func pullCount(for location: MapLocation) -> Int {
        itemPullCount[location, default: 0]
    }

    /// Increment the pull count for the given location.
    mutating func incrementPullCount() {
        itemPullCount[selected, default: 0] += 1
    }
}
