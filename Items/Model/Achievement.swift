//Created by Alexander Skorulis on 16/2/2026.

import Foundation

enum Achievement: Codable, Hashable {
    case items1
    case items10
    case items100
    
    var text: String {
        switch self {
        case .items1: return "Your first item"
        case .items10: return "Baby steps"
        case .items100: return "Getting somewhere"
        }
    }
    
    var requirement: AchievementRequirement {
        switch self {
        case .items1:
            return .itemsCreated(1)
        case .items10:
            return .itemsCreated(10)
        case .items100:
            return .itemsCreated(100)
        }
    }
    
    var bonusMessage: String? {
        switch self {
        case .items1:
            return nil
        case .items10:
            return "Research unlocked"
        case .items100:
            return "Recipes unlocked"
        }
    }
    
}

enum AchievementRequirement: Codable {
    case itemsCreated(Int64)
    case researchRuns(Int64)
}

extension AchievementRequirement {
    
    var description: String {
        switch self {
        case let .itemsCreated(count):
            return "Create \(count) items"
        case let .researchRuns(count):
            return "Research \(count) times"
        }
    }
}
