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

    /// Total meters explored by golem missions completed at each location.
    var golemExploredDistanceMeters: [MapLocation: Int] = [:]

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

    /// Total meters from completed golem missions at this location.
    func golemExploredDistance(for location: MapLocation) -> Int {
        golemExploredDistanceMeters[location, default: 0]
    }

    /// Adds meters explored from a completed golem mission at the given location.
    mutating func addGolemExploredDistance(_ meters: Int, for location: MapLocation) {
        guard meters > 0 else { return }
        golemExploredDistanceMeters[location, default: 0] += meters
    }
}
