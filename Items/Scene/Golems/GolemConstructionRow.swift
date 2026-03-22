// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models
import SwiftUI

@MainActor struct GolemConstructionRow {
    let golemType: GolemType
    let ownedCount: Int
    let itemQuantity: (BaseItem) -> Int
    let canPurchase: Bool
    let onPurchase: () -> Void
    let onInfo: () -> Void
}

extension GolemConstructionRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let image = golemType.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                Text(golemType.name)
                    .font(.appSectionTitle)
                Spacer()
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }
            Text(golemType.description)
                .font(.appCaption)
                .foregroundStyle(.secondary)
            Text("Owned: \(ownedCount)")
                .font(.appCaption)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                UpgradeCostRow(cost: golemType.cost, itemQuantity: itemQuantity)
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
    GolemConstructionRow(
        golemType: .clay,
        ownedCount: 2,
        itemQuantity: { _ in 5 },
        canPurchase: true,
        onPurchase: {},
        onInfo: {}
    )
    .padding()
}
