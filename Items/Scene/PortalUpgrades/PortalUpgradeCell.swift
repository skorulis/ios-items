//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct PortalUpgradeCell {
    let upgrade: PortalUpgrade
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
            
            HStack(spacing: 8) {
                ForEach(Array(upgrade.cost.enumerated()), id: \.offset) { _, costItem in
                    AvatarView(
                        text: costItem.item.name,
                        image: costItem.item.image,
                        border: costItem.item.quality.color,
                        badge: costItem.quantity > 1 ? "\(costItem.quantity)" : nil,
                        size: .small
                    )
                }
                Spacer()
                Button("Purchase", action: onPurchase)
                    .buttonStyle(CapsuleButtonStyle())
                    .disabled(!canPurchase)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}
