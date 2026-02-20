//Created by Alexander Skorulis on 16/2/2026.

import Knit
import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct AchievementDetailsView {
    
    struct Model {
        var value: Int64
        let total: Int64
    }
    
    @State var viewModel: AchievementDetailsViewModel
    
    var model: Model { viewModel.model }
}

// MARK: - Rendering

extension AchievementDetailsView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                AvatarView(
                    text: viewModel.achievement.name,
                    image: nil,
                    border: Color.gray,
                )
                Text(viewModel.achievement.name)
                    .font(.title)
                Spacer()
            }
            
            Text(viewModel.achievement.requirement.description)
            if let bonus = viewModel.achievement.bonusMessage {
                Text(bonus)
            }
            GoalProgressBar(value: model.value, total: model.total)
        }
        .padding(16)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    VStack {
        AchievementDetailsView(
            viewModel: assembler.resolver.achievementDetailsViewModel(achievement: .items1)
        )
        .background(CardBackground())
        
        AchievementDetailsView(
            viewModel: assembler.resolver.achievementDetailsViewModel(achievement: .items100)
        )
        .background(CardBackground())
    }
    .padding(16)
    
}

