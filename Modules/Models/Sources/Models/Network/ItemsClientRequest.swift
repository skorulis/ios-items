//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

// Requests sent to the client
public struct ItemsClientRequest: Codable {

    public let id: String
    public let payload: Payload

    public init(payload: Payload) {
        self.payload = payload
        self.id = UUID().uuidString
    }
    
    // The actual request type sent over the wire
    public enum Payload: Codable {
        case getItems
        case getActions
        case makeItem
        case getArtifacts
        case getUpgrades
        case getAchievements
        case purchaseUpgrade(PortalUpgrade)
    }
}
