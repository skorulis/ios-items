//Created for game statistics screen.

import ASKCoordinator
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct GameStatisticsView {
    @ObservedObject var viewModel: GameStatisticsViewModel
}

// MARK: - Rendering

extension GameStatisticsView: View {

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(
            title: "Statistics",
            backAction: { viewModel.coordinator?.pop() }
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.statRows.enumerated()), id: \.offset) { index, row in
                statRow(name: row.name, value: row.value, index: index)
            }
        }
        .padding(.horizontal, 16)
    }

    private func statRow(name: String, value: String, index: Int) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(name)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer(minLength: 16)
            Text(value)
                .font(.body.monospacedDigit())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(rowBackground(isAlternating: index.isMultiple(of: 2)))
    }

    /// Alternating subtle backgrounds so consecutive rows are easy to scan.
    private func rowBackground(isAlternating: Bool) -> Color {
        if isAlternating {
            return Color(.secondarySystemGroupedBackground)
        }
        return Color(.tertiarySystemGroupedBackground)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    GameStatisticsView(viewModel: assembler.resolver.gameStatisticsViewModel())
}
