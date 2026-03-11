//Created by Alexander Skorulis on 9/3/2026.

import Foundation

struct Recipes: Codable, Equatable {
    var sacrificesEnabled: Bool = true
    
    // A single config with 5 slots
    var sacrificeConfig: SacrificeConfig = SacrificeConfig()
}
