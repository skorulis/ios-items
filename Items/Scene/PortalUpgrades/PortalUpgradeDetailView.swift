// Created by Cursor on 24/3/2026.

import Models
import SwiftUI

@MainActor struct PortalUpgradeDetailView: View {

    let upgrade: PortalUpgrade
    @Bindable private var viewModel: PortalUpgradesViewModel

    init(upgrade: PortalUpgrade, viewModel: PortalUpgradesViewModel) {
        self.upgrade = upgrade
        self._viewModel = Bindable(wrappedValue: viewModel)
    }

    private var purchased: Bool {
        viewModel.purchasedUpgrades.purchased.contains(upgrade)
    }

    private var dialog: DefaultDialogContent.Model {
        upgrade.detailedExplanation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(dialog.title ?? upgrade.name)
                    .font(.appSectionTitle)
                Spacer()
                Button {
                    viewModel.showUpgradeLongFormExplanation(upgrade)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }
            Text(upgrade.description)
                .font(.appCaption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            if !purchased {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(upgrade.requirements.enumerated()), id: \.offset) { _, requirement in
                        if !viewModel.isRequirementComplete(requirement) {
                            Text("• \(requirement.description)")
                                .font(.appCaption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            if !upgrade.cost.isEmpty && !purchased {
                UpgradeCostRow(cost: upgrade.cost, itemQuantity: { viewModel.warehouse.quantity($0) })
            }

            if viewModel.isUnlocked(upgrade) && !purchased {
                Button("Purchase") {
                    withAnimation(.easeOut(duration: 0.3)) {
                        viewModel.purchase(upgrade)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canPurchase(upgrade))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}
