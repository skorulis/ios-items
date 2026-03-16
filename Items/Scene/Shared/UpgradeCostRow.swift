// Created by Cursor on 16/3/2026.
//
// Reusable view for displaying a list of item costs.

import Foundation
import Models
import SwiftUI

@MainActor struct UpgradeCostRow: View {

    /// Lines describing the cost (item and quantity).
    let cost: [UpgradeCostItem]

    /// Returns the current quantity for a given item.
    let itemQuantity: (BaseItem) -> Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(cost.enumerated()), id: \.offset) { _, costItem in
                HStack(spacing: 4) {
                    AvatarView(
                        text: costItem.item.name,
                        image: costItem.item.image,
                        border: costItem.item.quality.color,
                        size: .small
                    )
                    Text(quantityString(costItem: costItem))
                        .font(.caption)
                        .foregroundStyle(
                            itemQuantity(costItem.item) >= costItem.quantity ? Color.green : Color.red
                        )
                }
            }
        }
    }

    private func quantityString(costItem: UpgradeCostItem) -> String {
        let currentQuantity = min(itemQuantity(costItem.item), costItem.quantity)
        return "\(currentQuantity)/\(costItem.quantity)"
    }
}
