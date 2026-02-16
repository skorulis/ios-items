//Created by Alexander Skorulis on 16/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct AchievementDetailsView {
    let achievement: Achievement
}

// MARK: - Rendering

extension AchievementDetailsView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                AvatarView(
                    initials: achievement.acronym,
                    border: Color.gray,
                )
                Text(achievement.name)
                    .font(.title)
                Spacer()
            }
            
            Text(achievement.requirement.description)
            if let bonus = achievement.bonusMessage {
                Text(bonus)
            }
        }
        .padding(16)
        .background(CardBackground())
        .padding(16)
    }
}

// MARK: - Previews

#Preview {
    VStack {
        AchievementDetailsView(achievement: .items1)
        AchievementDetailsView(achievement: .items10)
    }
    
}

