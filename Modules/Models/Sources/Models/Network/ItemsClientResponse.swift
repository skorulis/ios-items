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
        case items([BaseItem: Int])
        case makeItemResult(MakeItemResult)
        case actions([GameAction], [GameData])
        case artifacts([Artifact: ItemQuality])
        case upgrades(UpgradesPayload)
        case error(String)
        case ok
    }
}

public struct UpgradesPayload: Codable {
    public let purchased: [PortalUpgrade]
    public let available: [PortalUpgrade]
    
    public init(purchased: [PortalUpgrade], available: [PortalUpgrade]) {
        self.purchased = purchased
        self.available = available
    }
}
