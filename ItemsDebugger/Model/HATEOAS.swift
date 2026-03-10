//Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Models

struct HATEOAS: Codable {
    let _links: [Link]
}

struct Link: Codable, Equatable, Hashable {
    let href: String
    let description: String
    let action: String
    
    init(action: GameAction) {
        self.href = action.href
        self.description = action.description
        self.action = "POST"
    }
    
    init(data: GameData) {
        self.href = data.href
        self.description = data.description
        self.action = "GET"
    }
}
