// Created by Alexander Skorulis on 21/2/2026.

import ASKCoordinator
import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct EncyclopediaView {
    @State var viewModel: EncyclopediaViewModel
}

// MARK: - Rendering

extension EncyclopediaView: View {

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var content: some View {
        VStack(alignment: .leading) {
            Text(viewModel.entry.body)
                .multilineTextAlignment(.leading)
            children
        }
        .margin()
    }

    private var children: some View {
        VStack(alignment: .leading, spacing: 0) {
            rootRows
            ForEach(viewModel.entry.childItems, id: \.title) { entry in
                if viewModel.isUnlocked(entry: entry) {
                    cell(entry: entry)
                } else {
                    lockedCell
                }
            }
        }
    }

    @ViewBuilder
    private var rootRows: some View {
        if viewModel.entry.isRoot {
            achievementsRow
            statisticsRow
        }
    }

    private var achievementsRow: some View {
        ChevronRow(
            title: "Achievements",
            leading: {
                Image(systemName: "fireworks")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .overlay(alignment: .trailing) {
                        achievementsbadge
                    }
            },
            action: { viewModel.showAchievements() }
        )
        .accessibilityLabel("Achievements")
    }

    private var achievementsbadge: some View {
        BadgeView(
            style: viewModel.achievementsNewCount > 0
                ? .number(viewModel.achievementsNewCount)
                : nil
        )
        .offset(x: 6)
    }

    private var statisticsRow: some View {
        ChevronRow(
            title: "Statistics",
            leading: {
                Image(systemName: "chart.bar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            },
            action: { viewModel.showStatistics() }
        )
        .accessibilityLabel("Statistics")
    }

    private var lockedCell: some View {
        ChevronRow(
            title: "<Locked>",
            leading: {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            },
            action: {}
        )
        .environment(\.isEnabled, false)
    }

    @ViewBuilder
    private func cell(entry: EncyclopediaEntry) -> some View {
        if let icon = entry.icon {
            ChevronRow(
                title: entry.title,
                leading: { icon },
                action: { viewModel.showChild(entry: entry)}
            )
        } else {
            ChevronRow(title: entry.title) {
                viewModel.showChild(entry: entry)
            }
        }
    }

    private var titleBar: some View {
        TitleBar(
            title: viewModel.entry.title,
            backAction: viewModel.backAction
        )
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    EncyclopediaView(viewModel: assembler.resolver.encyclopediaViewModel(entry: .root))
}
