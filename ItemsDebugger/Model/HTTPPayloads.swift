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

public struct HTTPAchievement: Codable {
    public let id: String
    public let requirementText: String
    public let bonusText: String?

    public init(achievement: Achievement) {
        self.id = achievement.rawValue
        self.requirementText = achievement.requirement.description
        self.bonusText = achievement.bonusMessage
    }
}
