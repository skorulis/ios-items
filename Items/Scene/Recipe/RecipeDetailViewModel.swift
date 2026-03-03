// Created by Cursor on 4/3/2026.

import Foundation
import Knit
import KnitMacros

@Observable
@MainActor
final class RecipeDetailViewModel {
    
    struct Model {
        let recipe: Recipe
        let qualityChances: [(ItemQuality, Double)]
        let essenceBonuses: [(Essence, Double)]
    }
    
    private let itemGeneratorService: ItemGeneratorService
    
    private(set) var model: Model
    
    @Resolvable<BaseResolver>
    init(
        itemGeneratorService: ItemGeneratorService,
        @Argument recipe: Recipe
    ) {
        self.itemGeneratorService = itemGeneratorService
        
        let info = itemGeneratorService.recipeInfo(recipe: recipe)
        
        let qualityChances = RecipeDetailViewModel.normalizedQualityChances(from: info.quality)
        let essenceBonuses = RecipeDetailViewModel.sortedEssenceBonuses(from: info.essenceBoosts)
        
        self.model = Model(
            recipe: recipe,
            qualityChances: qualityChances,
            essenceBonuses: essenceBonuses
        )
    }
    
    private static func normalizedQualityChances(
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
    
    private static func sortedEssenceBonuses(
        from boosts: [Essence: Double]
    ) -> [(Essence, Double)] {
        boosts
            .map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                lhs.0.name < rhs.0.name
            }
    }
}

