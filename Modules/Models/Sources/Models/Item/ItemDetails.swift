//  Created by Alexander Skorulis on 11/3/2026.

import Foundation

public struct ItemDetails: Codable {
    public let item: BaseItem
    public let doubleChance: String
    public let researchLevel: Int?
    
    // Number of items needed for the next level of research
    public let researchCost: Int?
    
    public init(
        item: BaseItem,
        doubleChance: String,
        researchLevel: Int?,
        researchCost: Int?,
    ) {
        self.item = item
        self.doubleChance = doubleChance
        self.researchLevel = researchLevel
        self.researchCost = researchCost
    }
}
