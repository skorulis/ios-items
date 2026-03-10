//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

// A response from the client
public struct ItemsClientResponse: Codable {

    // Will match the request ID
    public let id: String
    public let payload: Payload

    public init(id: String, payload: Payload) {
        self.id = id
        self.payload = payload
    }
    
    // The actual response type sent over the wire
    public enum Payload: Codable {
        case items([BaseItem: ItemWithDetails])
        case makeItemResult(MakeItemResult)
        case actions([GameAction], [GameData])
        case artifacts([Artifact: ItemQuality])
        case upgrades(UpgradesPayload)
        case achievements(completed: [Achievement], incomplete: [IncompleteAchievement])
        case error(String)
        case ok
    }
}

public struct ItemWithDetails: Codable {
    public let count: Int
    public let details: ItemDetails
    
    public init(count: Int, details: ItemDetails) {
        self.count = count
        self.details = details
    }
}

/// An achievement that is not yet completed, with current progress toward its requirement.
public struct IncompleteAchievement: Codable {
    public let achievement: Achievement
    public let currentProgress: Int64
    public let total: Int64

    public init(achievement: Achievement, currentProgress: Int64, total: Int64) {
        self.achievement = achievement
        self.currentProgress = currentProgress
        self.total = total
    }
}

public struct UpgradesPayload: Codable {
    public let purchased: [PortalUpgrade]
    public let unlocked: [PortalUpgrade]
    public let affordable: [PortalUpgrade]

    public init(purchased: [PortalUpgrade], unlocked: [PortalUpgrade], affordable: [PortalUpgrade]) {
        self.purchased = purchased
        self.unlocked = unlocked
        self.affordable = affordable
    }
}
