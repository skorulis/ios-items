//  Created by Alex Skorulis on 16/3/2026.

import Foundation

/// A single line in an upgrade's cost: item type and required quantity.
public struct UpgradeCostItem: Codable, Hashable, Sendable {
    public let item: Ingredient
    public let quantity: Int

    public init(item: Ingredient, quantity: Int) {
        self.item = item
        self.quantity = quantity
    }
}
