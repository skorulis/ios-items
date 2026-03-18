// Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct PortalUpgradeCell {
    let upgrade: PortalUpgrade
    let itemQuantity: (BaseItem) -> Int
    let canPurchase: Bool
    let onPurchase: () -> Void
    let onInfo: () -> Void
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
                    .font(.appSectionTitle)
                Spacer()
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }
            Text(upgrade.description)
                .font(.appCaption)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                UpgradeCostRow(cost: upgrade.cost, itemQuantity: itemQuantity)
                    .layoutPriority(1)
                Spacer(minLength: 8)
                Button("Purchase", action: onPurchase)
                    .buttonStyle(CapsuleButtonStyle())
                    .disabled(!canPurchase)
                    .layoutPriority(2)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PortalUpgradeCell(
        upgrade: .knowledgeSiphonLevel3,
        itemQuantity: { _ in 5},
        canPurchase: true,
        onPurchase: {},
        onInfo: {}
    )
    .padding()
}
