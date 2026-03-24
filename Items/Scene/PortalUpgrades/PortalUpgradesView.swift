// Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct PortalUpgradesView {
    @State var viewModel: PortalUpgradesViewModel
    @Environment(\.dismissCircularReveal) private var dismissCircularReveal
}

// MARK: - Rendering

extension PortalUpgradesView: View {

    var body: some View {
        PageLayout(
            scrollEnabled: false,
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(
            title: "Portal Upgrades",
            backAction: {
                if let dismissCircularReveal {
                    dismissCircularReveal()
                } else {
                    viewModel.pop()
                }
            },
            leadingStyle: .close
        )
    }

    private var content: some View {
        techTree
            .padding(.vertical, 8)
    }

    private var techTree: some View {
        let canvasSize = PortalUpgradeTreeLayout.canvasSize
        let hub = PortalUpgradeTreeLayout.center(for: .portalUnlocked)
        return ZoomingScrollView(
            contentSize: canvasSize,
            initialCenterPoint: hub
        ) {
            ZStack(alignment: .topLeading) {
                PortalUpgradeTreeLinesView()
                ForEach(PortalUpgrade.allCases) { upgrade in
                    portalNode(upgrade: upgrade)
                        .position(PortalUpgradeTreeLayout.center(for: upgrade))
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
        }
    }

    private func portalNode(upgrade: PortalUpgrade) -> some View {
        let purchased = viewModel.purchasedUpgrades.purchased.contains(upgrade)
        let unlocked = viewModel.isUnlocked(upgrade)
        let canBuy = viewModel.canPurchase(upgrade)
        let lockedDim: Double = (unlocked || purchased) ? 1 : 0.55

        let borderColor: Color = {
            if purchased { return .green }
            if canBuy { return Color.accentColor }
            return Color.gray.opacity(0.35)
        }()
        let borderWidth: CGFloat = {
            if purchased { return 4.5 }
            if canBuy { return 3 }
            return 1.5
        }()

        return Button {
            viewModel.showUpgradeDetail(upgrade)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.12))
                    .overlay {
                        Circle()
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                upgrade.layeredIcon.size(37)
                    .foregroundStyle(unlocked || purchased ? Color.primary : Color.secondary)
            }
        }
        .buttonStyle(.plain)
        .frame(width: PortalUpgradeTreeLayout.nodeSize, height: PortalUpgradeTreeLayout.nodeSize)
        .opacity(lockedDim)
        .accessibilityLabel(accessibilityLabel(upgrade: upgrade, purchased: purchased, unlocked: unlocked))
    }

    private func accessibilityLabel(upgrade: PortalUpgrade, purchased: Bool, unlocked: Bool) -> String {
        if purchased { return "\(upgrade.name), purchased" }
        if unlocked { return "\(upgrade.name), unlocked" }
        return "\(upgrade.name), locked"
    }
}

// MARK: - Tree edges

private struct PortalUpgradeTreeLinesView: View {
    var body: some View {
        Canvas { context, _ in
            for upgrade in PortalUpgrade.allCases {
                guard let parent = upgrade.treeParent else { continue }
                let (from, to) = PortalUpgradeTreeLayout.lineEndPoints(parent: parent, child: upgrade)
                var path = Path()
                path.move(to: from)
                path.addLine(to: to)
                context.stroke(
                    path,
                    with: .color(.gray.opacity(0.4)),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .frame(width: PortalUpgradeTreeLayout.canvasSize.width, height: PortalUpgradeTreeLayout.canvasSize.height)
        .allowsHitTesting(false)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    PortalUpgradesView(viewModel: assembler.resolver.portalUpgradesViewModel())
}
