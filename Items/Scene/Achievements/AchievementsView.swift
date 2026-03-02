//Created by Alexander Skorulis on 16/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct AchievementsView {
    @State var viewModel: AchievementsViewModel
}

// MARK: - Rendering

extension AchievementsView: View {
    
    var body: some View {
        PageLayout(
            titleBar: { titleBar},
            content: { content }
        )
    }
    
    private var content: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80)),
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Achievement.allCases) { achievement in
                cell(achievement: achievement)
            }
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func cell(achievement: Achievement) -> some View {
        let complete = viewModel.isComplete(achievement: achievement)
        Button(action: { viewModel.showDetails(achievement: achievement)}) {
            AvatarView(
                text: achievement.name,
                image: achievement.image,
                border: Color.gray,
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

