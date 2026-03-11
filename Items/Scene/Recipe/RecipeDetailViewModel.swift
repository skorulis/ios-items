// Created by Cursor on 4/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

@MainActor protocol RecipeDetailViewModel {
    var model: RecipeDetailView.Model { get }
}

extension RecipeDetailViewModel {
    static func normalizedQualityChances(
        from weights: [ItemQuality: Double]
    ) -> [(ItemQuality, Double)] {
        let total = weights.values.reduce(0, +)
        guard total > 0 else {
            return []
        }
        
        return ItemQuality.allCases
            .compactMap { quality -> (ItemQuality, Double)? in
                let weight = weights[quality, default: 0]
                guard weight > 0 else { return nil }
                let percentage = weight / total
                return (quality, percentage)
            }
    }
    
    static func sortedEssenceBonuses(
        from boosts: [Essence: Double]
    ) -> [(Essence, Double)] {
        boosts
            .map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                lhs.0.name < rhs.0.name
            }
    }
}
