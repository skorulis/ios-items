//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class CreationViewModel: CoordinatorViewModel {
    
    var coordinator: ASKCoordinator.Coordinator?
    private(set) var recipesAvailable: Bool = false
    private(set) var createdItem: BaseItem?
    private(set) var isCreating: Bool = false
    var automateCreation: Bool = false
    
    private let itemGeneratorService: ItemGeneratorService
    private let mainStore: MainStore
    private let recipeService: RecipeService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(itemGeneratorService: ItemGeneratorService, mainStore: MainStore, recipeService: RecipeService) {
        self.itemGeneratorService = itemGeneratorService
        self.mainStore = mainStore
        self.recipeService = recipeService
        
        mainStore.$warehouse.sink { warehouse in
            self.recipesAvailable = warehouse.totalItemsCollected >= 10
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension CreationViewModel {
    
    static let makeDelay: Int = 1000
    
    func make() async {
        self.isCreating = true
        self.createdItem = nil
        let recipe = recipeService.nextAvailable()
        recipeService.consumeRecipe(recipe)
        
        try? await Task.sleep(for: .milliseconds(Self.makeDelay))
        self.isCreating = false
        
        let item = itemGeneratorService.make(recipe: recipe)
        mainStore.warehouse.add(item: item)
        
        mainStore.statistics.itemsCreated += 1
        mainStore.statistics.itemsDestroyed += Int64(recipe.items.count)
        
        self.createdItem = item
    }
    
    func showRecipes() {
        coordinator?.push(MainPath.recipeList)
    }
    
}
