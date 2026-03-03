//Created by Alexander Skorulis on 16/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct AchievementsView {
    @State var viewModel: AchievementsViewModel

    struct Model {
        var newAchievementsToShow: Set<Achievement> = []
    }
}

// MARK: - Rendering

extension AchievementsView: View {
    
    var body: some View {
        PageLayout(
            titleBar: { titleBar},
            content: { content }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var content: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80)),
        ]
        let grouped = Dictionary(grouping: Achievement.allCases, by: { $0.quality })

        return LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(ItemQuality.allCases, id: \.self) { quality in
                if let achievementsInQuality = grouped[quality], !achievementsInQuality.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quality.name)
                            .font(.headline)
                            .foregroundStyle(quality.color)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(achievementsInQuality) { achievement in
                                cell(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func cell(achievement: Achievement) -> some View {
        let complete = viewModel.isComplete(achievement: achievement)
        let isNew = viewModel.model.newAchievementsToShow.contains(achievement)
        Button(action: { viewModel.showDetails(achievement: achievement)}) {
            AvatarView(
                text: achievement.name,
                image: achievement.image,
                border: achievement.quality.color,
                showNewBadge: isNew
            )
        }
        .grayscale(complete ? 0 : 1)
    }
    
    private var titleBar: some View {
        TitleBar(
            title: "Achievements",
        )
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    AchievementsView(viewModel: assembler.resolver.achievementsViewModel())
}

