//Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Models

struct HTTPPortalUpgrade: Codable {
    
    let id: String
    let name: String
    let bonus: String
    let itemCost: [String: Int]
    
    init(upgrade: PortalUpgrade) {
        self.id = upgrade.rawValue
        self.name = upgrade.name
        self.bonus = upgrade.description
        self.itemCost = Dictionary(grouping: upgrade.cost, by: { $0.item.rawValue})
            .mapValues { $0[0].quantity }
    }
}
