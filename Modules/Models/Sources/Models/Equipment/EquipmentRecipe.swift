//  Created by Alexander Skorulis on 25/3/2026.

import Foundation

// A Recipe to create
public enum EquipmentRecipe {
    
    case stoneDagger
    
    public var cost: [UpgradeCostItem] {
        switch self {
        case .stoneDagger:
            return [.init(item: .rock, quantity: 50)]
        }
    }
}
