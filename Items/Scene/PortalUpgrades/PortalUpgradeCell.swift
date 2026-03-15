//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct PortalUpgradeCell {
    let upgrade: PortalUpgrade
    let itemQuantity: (BaseItem) -> Int
    let canPurchase: Bool
    let onPurchase: () -> Void
}

// MARK: - Rendering

extension PortalUpgradeCell: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let image = upgrade.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                Text(upgrade.name)
                    .font(.headline)
            }
            Text(upgrade.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            cost
        }
        .padding(12)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var cost: some View {
        HStack(spacing: 8) {
            ForEach(Array(upgrade.cost.enumerated()), id: \.offset) { _, costItem in
                HStack(spacing: 4) {
                    AvatarView(
                        text: costItem.item.name,
                        image: costItem.item.image,
                        border: costItem.item.quality.color,
                        badge: nil,
                        size: .small
                    )
                    Text(quantityString(costItem: costItem))
                        .font(.caption)
                        .foregroundStyle(itemQuantity(costItem.item) >= costItem.quantity ? Color.green : Color.red)
                }
            }
            Spacer()
            Button("Purchase", action: onPurchase)
                .buttonStyle(CapsuleButtonStyle())
                .disabled(!canPurchase)
        }
    }
    
    private func quantityString(costItem: UpgradeCostItem) -> String {
        let currentQuantity = min(itemQuantity(costItem.item), costItem.quantity)
        return "\(currentQuantity)/\(costItem.quantity)"
    }
}
