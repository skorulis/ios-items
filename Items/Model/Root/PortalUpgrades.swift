//Created by Alexander Skorulis on 5/3/2026.

import Foundation

struct PortalUpgrades: Codable {
    
    var purchased: Set<PortalUpgrade> = []
    
    // All bonsues for purchased upgrades
    var bonuses: [Bonus] {
        return purchased.compactMap { $0.bonus }
    }
}
