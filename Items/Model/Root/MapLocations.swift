// Created by Cursor on 16/3/2026.
//
// Root model for world map location state stored in MainStore.

import Foundation
import Models

struct MapLocations: Codable {

    /// Locations that have been unlocked by the player.
    var unlocked: Set<MapLocation> = [.vesprium]
    
    var selected: MapLocation = .vesprium

    /// Whether a given location is unlocked.
    func isUnlocked(_ location: MapLocation) -> Bool {
        unlocked.contains(location)
    }
}

