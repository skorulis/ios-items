//Created by Alexander Skorulis on 5/3/2026.

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
        VStack(alignment: .leading, spacing: 12) {
            Picker("Mode", selection: $viewModel.segment) {
                ForEach(PortalUpgradesViewModel.Segment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            switch viewModel.segment {
            case .purchase:
                purchaseList
            case .purchased:
                purchasedList
            }
        }
    }

    private var purchaseList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.availableToPurchase, id: \.self) { upgrade in
                PortalUpgradeCell(
                    upgrade: upgrade,
                    itemQuantity: { viewModel.warehouse.quantity($0) },
                    canPurchase: viewModel.canPurchase(upgrade),
                    onPurchase: { viewModel.purchase(upgrade) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var purchasedList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.purchased, id: \.self) { upgrade in
                purchasedRow(upgrade: upgrade)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func purchasedRow(upgrade: PortalUpgrade) -> some View {
        VStack(alignment: .leading, spacing: 4) {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    PortalUpgradesView(viewModel: assembler.resolver.portalUpgradesViewModel())
}
