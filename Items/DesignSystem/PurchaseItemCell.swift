// Created by Cursor on 23/3/2026.

import Foundation
import Models
import SwiftUI

/// Shared card for purchasing or unlocking an item (portal upgrades, golems, map locations, etc.).
@MainActor struct PurchaseItemCell<Leading: View>: View {

    enum ActionStyle: Equatable {
        /// Cost chips on the left, capsule purchase button on the right (portal upgrades, golems).
        case capsuleBesideCost
        /// Optional cost row, then a full-width prominent button (map locations).
        case fullWidthBorderedProminent(actionTopPadding: CGFloat = 4)
    }

    private let leading: Leading
    private let title: String
    private let description: String
    private let extraCaption: String?
    private let cost: [UpgradeCostItem]
    private let itemQuantity: (BaseItem) -> Int
    private let actionStyle: ActionStyle
    private let purchaseTitle: String
    private let canPurchase: Bool
    private let onPurchase: () -> Void
    private let onInfo: () -> Void

    init(
        @ViewBuilder leading: () -> Leading,
        title: String,
        description: String,
        extraCaption: String? = nil,
        cost: [UpgradeCostItem],
        itemQuantity: @escaping (BaseItem) -> Int,
        actionStyle: ActionStyle,
        canPurchase: Bool,
        purchaseTitle: String,
        onPurchase: @escaping () -> Void,
        onInfo: @escaping () -> Void
    ) {
        self.leading = leading()
        self.title = title
        self.description = description
        self.extraCaption = extraCaption
        self.cost = cost
        self.itemQuantity = itemQuantity
        self.actionStyle = actionStyle
        self.canPurchase = canPurchase
        self.purchaseTitle = purchaseTitle
        self.onPurchase = onPurchase
        self.onInfo = onInfo
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                leading
                Text(title)
                    .font(.appSectionTitle)
                Spacer()
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }
            Text(description)
                .font(.appCaption)
                .foregroundStyle(.secondary)
            if let extraCaption {
                Text(extraCaption)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            switch actionStyle {
            case .capsuleBesideCost:
                HStack(spacing: 0) {
                    UpgradeCostRow(cost: cost, itemQuantity: itemQuantity)
                        .layoutPriority(1)
                    Spacer(minLength: 8)
                    Button(purchaseTitle, action: onPurchase)
                        .buttonStyle(CapsuleButtonStyle())
                        .layoutPriority(2)
                        .disabled(!canPurchase)
                }
            case .fullWidthBorderedProminent(let actionTopPadding):
                if !cost.isEmpty {
                    UpgradeCostRow(cost: cost, itemQuantity: itemQuantity)
                }
                Button(action: onPurchase) {
                    Text(purchaseTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, actionTopPadding)
                .disabled(!canPurchase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("Capsule") {
    PurchaseItemCell(
        leading: {
            Image(systemName: "wand.and.stars")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        },
        title: "Sample upgrade",
        description: "Does something useful.",
        extraCaption: "Owned: 2",
        cost: [],
        itemQuantity: { _ in 0 },
        actionStyle: .capsuleBesideCost,
        canPurchase: false,
        purchaseTitle: "Purchase",
        onPurchase: {},
        onInfo: {}
    )
    .disabled(true)
    .padding()
}

#Preview("Full width") {
    PurchaseItemCell(
        leading: {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .center)
        },
        title: "Forest",
        description: "A wooded area.",
        cost: [],
        itemQuantity: { _ in 0 },
        actionStyle: .fullWidthBorderedProminent(),
        canPurchase: true,
        purchaseTitle: "Unlock",
        onPurchase: {},
        onInfo: {}
    )
    .padding()
}
