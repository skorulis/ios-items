//Created for Essence Breakdown feature.

import ASKCoordinator
import Charts
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct EssenceBreakdownView {
    @State var viewModel: EssenceBreakdownViewModel
}

// MARK: - Rendering

extension EssenceBreakdownView: View {

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(
            title: "Essence breakdown",
            backAction: { viewModel.coordinator?.retreat() }
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            filterSection
            chartSection
            legendSection
        }
        .padding(.horizontal, 16)
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quality filter")
                .font(.headline)
            Picker("Quality", selection: Binding(
                get: { viewModel.selectedQualityFilter },
                set: { viewModel.selectedQualityFilter = $0 }
            )) {
                Text("All")
                    .tag(Optional<ItemQuality>.none)
                ForEach(ItemQuality.allCases, id: \.self) { quality in
                    Text(quality.name)
                        .tag(Optional(quality))
                }
            }
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder
    private var chartSection: some View {
        if viewModel.hasAnyCounts {
            let segments = viewModel.essenceCounts.filter { $0.1 > 0 }
            Chart(segments, id: \.0) { item in
                let (essence, count) = item
                SectorMark(
                    angle: .value("Count", count),
                    innerRadius: .ratio(0.4),
                    angularInset: 1.5
                )
                .foregroundStyle(essence.color)
                .cornerRadius(3)
            }
            .frame(height: 220)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Essence breakdown chart")
            .accessibilityValue(segments.map { "\($0.0.name): \($0.1)" }.joined(separator: ", "))
        } else {
            Text("No essences for this quality")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
        }
    }

    private var legendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Counts")
                .font(.headline)
            ForEach(viewModel.essenceCounts, id: \.0) { essence, count in
                HStack {
                    EssenceView(essence: essence)
                    Text(essence.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(count)")
                        .font(.body.monospacedDigit())
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(essence.name): \(count)")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    return EssenceBreakdownView(viewModel: assembler.resolver.essenceBreakdownViewModel())
}
