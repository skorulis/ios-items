//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class CreationViewModel: CoordinatorViewModel {
    
    private var makeTimer: Timer?
    
    var model = CreationView.Model()
    
    var coordinator: ASKCoordinator.Coordinator?
    
    var automateCreation: Bool = false
    {
        didSet {
            if automateCreation {
                startMakeTimer()
            } else {
                stopMakeTimer()
            }
        }
    }
    
    private let itemGeneratorService: ItemGeneratorService
    private let calculations: CalculationsService
    private let mainStore: MainStore
    private let recipeService: RecipeService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(
        itemGeneratorService: ItemGeneratorService,
        mainStore: MainStore,
        recipeService: RecipeService,
        calculations: CalculationsService,
    ) {
        self.itemGeneratorService = itemGeneratorService
        self.mainStore = mainStore
        self.recipeService = recipeService
        self.calculations = calculations
        
        mainStore.$warehouse.sink { warehouse in
            self.model.warehouse = warehouse
        }
        .store(in: &cancellables)
        
        mainStore.$recipes.sink { recipes in
            self.model.recipes = recipes
        }
        .store(in: &cancellables)
    }
    
    deinit {
        stopMakeTimer()
    }

    private func startMakeTimer() {
        stopMakeTimer()
        let time = calculations.autoCreationMilliseconds / 1000
        makeTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard self?.model.isCreating == false else { return }
                await self?.make()
                if self?.automateCreation == true {
                    self?.startMakeTimer()
                }
            }
        }
    }

    private func stopMakeTimer() {
        makeTimer?.invalidate()
        makeTimer = nil
    }
}

// MARK: - Logic

extension CreationViewModel {
    
    func make() async {
        if model.isCreating { return }
        self.model.isCreating = true
        self.model.createdItem = nil
        let recipe = recipeService.nextAvailable()
        recipeService.consumeRecipe(recipe)
        mainStore.statistics.itemsDestroyed += Int64(recipe.items.count)
        
        try? await Task.sleep(for: .milliseconds(calculations.itemCreationMilliseconds))
        self.model.isCreating = false
        
        let item = itemGeneratorService.make(recipe: recipe)
        switch item {
        case let .base(baseItem, count):
            mainStore.warehouse.add(item: baseItem, count: count)
            
            mainStore.statistics.itemsCreated += Int64(count)
            if count > 1 {
                mainStore.statistics.doubleItemCreations += 1
            }
        case let .artifact(artifact):
            mainStore.warehouse.add(artifact: artifact)
        }
        
        self.model.createdItem = item
    }
    
    func showRecipes() {
        coordinator?.push(MainPath.recipeList)
    }
    
    func showDetails(item: BaseItem) {
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }
    
}
