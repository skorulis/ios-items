// Created by Cursor on 4/3/2026.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor
struct SacrificeDetailView {
    @State var viewModel: SacrificeDetailViewModel

    struct Model {
        let plan: SacrificePlan
        let qualityChances: [(ItemQuality, Double)]
        let essenceBonuses: [(Essence, Double)]
        let multipleItemsChancePercent: Int
    }
}

// MARK: - Rendering

extension SacrificeDetailView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            multipleItemsSection
            qualitySection
            essenceSection
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Creation")
                .font(.appTitle)
            if !viewModel.model.plan.consumedItems.isEmpty {
                Text(sacrificeDescription)
                    .font(.appSubheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var sacrificeDescription: String {
        let names = viewModel.model.plan.consumedItems.map(\.name)
        return names.joined(separator: " + ")
    }

    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quality chances")
                .font(.appTitle)

            ForEach(viewModel.model.qualityChances, id: \.0) { quality, chance in
                HStack {
                    Text(quality.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .foregroundStyle(quality.color)
                    Text(formatPercentage(chance))
                        .font(.appBody.monospacedDigit())
                        .frame(alignment: .trailing)
                }
            }
        }
    }

    @ViewBuilder
    private var multipleItemsSection: some View {
        if viewModel.model.multipleItemsChancePercent > 0 {
            HStack {
                Text("Extra item chance")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(viewModel.model.multipleItemsChancePercent)%")
                    .font(.appBody.monospacedDigit())
                    .frame(alignment: .trailing)
            }
        }
    }

    @ViewBuilder
    private var essenceSection: some View {
        if !viewModel.model.essenceBonuses.isEmpty {
            EssenceBonusesSectionView(
                title: "Essence bonuses",
                bonuses: viewModel.model.essenceBonuses
            )
        }
    }

    private func formatPercentage(_ value: Double) -> String {
        let percentage = value * 100
        return String(format: "%.0f%%", percentage)
    }

}
