//Created by Alexander Skorulis on 22/2/2026.

import Foundation

enum UnlockRequirement: Codable {
    case itemsCreated(Int64)
    case researchRuns(Int64)
    case commonItemsCreated(Int64)
    
    // How many essences have been unlocked
    case essencesUnlocked(Int64)
    
    // If a specific essence has been unlocked
    case essenceUnlocked(Essence)
}

extension UnlockRequirement {
    
    var description: String {
        switch self {
        case let .itemsCreated(count):
            return "Create \(count) items"
        case let .researchRuns(count):
            return "Research \(count) times"
        case let .commonItemsCreated(count):
            return "Create \(count) common items"
        case let .essencesUnlocked(count):
            return "\(count) Essences discovered"
        case let .essenceUnlocked(essence):
            return "\(essence.name) discovered"
        }
    }
}
