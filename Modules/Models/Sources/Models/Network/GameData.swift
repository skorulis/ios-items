//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

// GET actions to access app data
public enum GameData: Codable, Sendable {
    case items
    case artifacts
    case upgrades
    case achievements

    public var description: String {
        switch self {
        case .items:
            return "Get the current item storage"
        case .artifacts:
            return "Get the current level of artifacts"
        case .upgrades:
            return "Get the current available and purchased upgrades"
        case .achievements:
            return "Get the current achievements (completed and incomplete)"
        }
    }
}
