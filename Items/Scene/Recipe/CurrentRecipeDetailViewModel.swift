//Created by Alexander Skorulis on 9/3/2026.

import ASKCore
import Combine
import Knit
import KnitMacros
import Foundation
import SwiftUI

@Observable
final class CurrentRecipeDetailViewModel: RecipeDetailViewModel {
    
    private let recipeService: RecipeService
    private let itemGeneratorService: ItemGeneratorService
    
    var model: RecipeDetailView.Model = .init(
        plan: .init(itemsInOrder: []),
        qualityChances: [],
        essenceBonuses: []
    )
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(
        recipeService: RecipeService,
        itemGeneratorService: ItemGeneratorService,
        mainStore: MainStore,
    ) {
        self.recipeService = recipeService
        self.itemGeneratorService = itemGeneratorService
        
        self.model = makeModel()
        
        mainStore.$warehouse.delayedChange().sink { [unowned self] _ in
            self.model = self.makeModel()
        }
        .store(in: &cancellables)
    }
    
    private func makeModel() -> RecipeDetailView.Model {
        let plan = recipeService.sacrificeConsumptionPlan()
        let info = itemGeneratorService.recipeInfo(plan: plan)
        let qualityChances = Self.normalizedQualityChances(from: info.quality)
        let essenceBonuses = Self.sortedEssenceBonuses(from: info.essenceBoosts)
        return RecipeDetailView.Model(
            plan: plan,
            qualityChances: qualityChances,
            essenceBonuses: essenceBonuses
        )
    }
}

