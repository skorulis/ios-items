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
        ScrollViewReader { scrollProxy in
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    PortalUpgradeTreeLinesView()
                    Color.clear
                        .frame(width: PortalUpgradeTreeLayout.nodeSize, height: PortalUpgradeTreeLayout.nodeSize)
                        .position(PortalUpgradeTreeLayout.center(for: .portalUnlocked))
                        .allowsHitTesting(false)
                        .id(PortalUpgradeTreeLayout.scrollCenterViewID)
                    ForEach(PortalUpgrade.allCases) { upgrade in
                        portalNode(upgrade: upgrade)
                            .position(PortalUpgradeTreeLayout.center(for: upgrade))
                    }
                }
                .frame(
                    width: PortalUpgradeTreeLayout.canvasSize.width,
                    height: PortalUpgradeTreeLayout.canvasSize.height
                )
            }
            .onAppear {
                scrollToHubIfNeeded(using: scrollProxy)
            }
        }
    }

    private func scrollToHubIfNeeded(using scrollProxy: ScrollViewProxy) {
        if ProcessInfo.isRunningTests {
            scrollProxy.scrollTo(PortalUpgradeTreeLayout.scrollCenterViewID, anchor: .center)
            return
        }
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.2)) {
                scrollProxy.scrollTo(PortalUpgradeTreeLayout.scrollCenterViewID, anchor: .center)
            }
        }
    }

    private func portalNode(upgrade: PortalUpgrade) -> some View {
        let purchased = viewModel.purchasedUpgrades.purchased.contains(upgrade)
        let unlocked = viewModel.isUnlocked(upgrade)
        let canBuy = viewModel.canPurchase(upgrade)
        let lockedDim: Double = (unlocked || purchased) ? 1 : 0.55

        return Button {
            viewModel.showUpgradeDetail(upgrade)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.12))
                    .overlay {
                        Circle()
                            .stroke(
                                canBuy && !purchased ? Color.accentColor : Color.gray.opacity(0.35),
                                lineWidth: canBuy && !purchased ? 3 : 1.5
                            )
                    }
                if let image = upgrade.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 26, height: 26)
                        .foregroundStyle(unlocked || purchased ? Color.primary : Color.secondary)
                }
                if purchased {
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.accentColor)
                        .font(.system(size: 16))
                        .offset(x: 16, y: -16)
                }
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
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
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
