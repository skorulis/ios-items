// Created by Cursor on 20/3/2026.

import Foundation
import Models
import SwiftUI

@MainActor
struct EssenceBonusesSectionView: View {
    let title: String
    let bonuses: [(Essence, Double)]

    var body: some View {
        let nonZeroBonuses = bonuses.filter { $0.1 > 0 }
        let zeroBonuses = bonuses.filter { $0.1 <= 0 }

        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appTitle)

            ForEach(nonZeroBonuses, id: \.0) { essence, boost in
                HStack {
                    HStack(spacing: 8) {
                        EssenceView(essence: essence)
                        Text(essence.name)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(formatMultiplier(boost))
                        .font(.appBody.monospacedDigit())
                        .frame(alignment: .trailing)
                }
            }

            if !zeroBonuses.isEmpty {
                HStack(spacing: 8) {
                    ForEach(zeroBonuses, id: \.0) { essence, _ in
                        ZStack {
                            EssenceView(essence: essence)
                            Rectangle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 2, height: 22)
                                .rotationEffect(.degrees(45))
                        }
                    }
                }
            }
        }
    }

    private func formatMultiplier(_ value: Double) -> String {
        // Essence boosts are multiplicative factors starting at 1.
        String(format: "x%.1f", value)
    }
}

#Preview {
    EssenceBonusesSectionView(
        title: "Essence bonuses",
        bonuses: [
            (.wealth, 1.5),
            (.knowledge, 1.1),
            (.dark, 0),
            (.earth, 0),
        ]
    )
}
