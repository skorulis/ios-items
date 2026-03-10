//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

// POST actions that can currently be done
public enum GameAction: String, Codable, Sendable {
    case makeItem
    case purchaseUpgrade
    
    public var description: String {
        switch self {
        case .makeItem:
            return "Pull a new random item from the portal"
        case .purchaseUpgrade:
            return "Purchase an upgrade to the portal"
        }
    }
}
