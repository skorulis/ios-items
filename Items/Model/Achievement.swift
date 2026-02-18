//Created by Alexander Skorulis on 16/2/2026.

import Foundation

enum Achievement: Codable, Hashable, CaseIterable, Identifiable {
    case items1
    case items10
    case items100
    
    var id: Self { self }
    
    var name: String {
        switch self {
        case .items1: return "Your first item"
        case .items10: return "Baby steps"
        case .items100: return "Getting somewhere"
        }
    }
    
    var acronym: String {
        String(String(describing: self).prefix(2))
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
            return "Sacrifices unlocked"
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
