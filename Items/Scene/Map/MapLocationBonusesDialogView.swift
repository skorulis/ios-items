// Created by Cursor on 20/3/2026.

import Foundation
import Models
import SwiftUI

struct MapLocationBonusesDialogView: View {
    let location: MapLocation

    private var details: LocationDetails {
        location.details
    }

    private var sortedEssenceBonuses: [(essence: Essence, multiplier: Double)] {
        details.essenceMultipliers
            .map { ($0.key, $0.value) }
            .sorted { $0.essence.name < $1.essence.name }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(location.name) Bonuses")
                .font(.appTitle)

            if sortedEssenceBonuses.isEmpty && details.uniqueItems.isEmpty {
                Text("No special location bonuses.")
                    .font(.appBody)
            } else {
                if !sortedEssenceBonuses.isEmpty {
                    EssenceBonusesSectionView(
                        title: "Essence bonuses",
                        bonuses: sortedEssenceBonuses.map { ($0.essence, $0.multiplier) }
                    )
                }

                if !details.uniqueItems.isEmpty {
                    section(title: "Unique Items") {
                        ForEach(details.uniqueItems, id: \.self) { item in
                            Text("• \(item.name)")
                                .font(.appBody)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appSectionTitle)
            content()
        }
    }
}

#Preview {
    MapLocationBonusesDialogView(location: .semilTradingPost)
}
