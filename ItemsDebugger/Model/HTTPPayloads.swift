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

struct HTTPMakeItem: Codable {
    let item: MakeItemResult
    let _newLinks: [Link]?
    
    init(item: MakeItemResult, diff: CacheDiff) {
        self.item = item
        _newLinks = diff.links
    }
}

struct OkResponse: Codable {
    let status: String
    let _newLinks: [Link]?
    
    init(status: String = "ok", diff: CacheDiff) {
        self.status = status
        _newLinks = diff.links
    }
}

public struct HTTPAchievement: Codable {
    public let id: String
    public let requirementText: String
    public let bonusText: String?
    public let progress: String?

    public init(achievement: Achievement, currentProgress: Int64? = nil, total: Int64? = nil) {
        self.id = achievement.rawValue
        self.requirementText = achievement.requirement.description
        self.bonusText = achievement.bonusMessage
        if let currentProgress, let total {
            self.progress = "\(currentProgress)/\(total)"
        } else {
            self.progress = nil
        }
    }
}
