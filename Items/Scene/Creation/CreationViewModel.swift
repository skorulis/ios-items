//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class CreationViewModel: CoordinatorViewModel {
    
    private var makeTimer: Timer?
    
    var coordinator: ASKCoordinator.Coordinator?
    private(set) var recipesAvailable: Bool = false
    private(set) var createdItem: BaseItem?
    private(set) var isCreating: Bool = false
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
            self.recipesAvailable = warehouse.totalItemsCollected >= 10
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
                guard self?.isCreating == false else { return }
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
        if isCreating { return }
        self.isCreating = true
        self.createdItem = nil
        let recipe = recipeService.nextAvailable()
        recipeService.consumeRecipe(recipe)
        
        try? await Task.sleep(for: .milliseconds(calculations.itemCreationMilliseconds))
        self.isCreating = false
        
        let item = itemGeneratorService.make(recipe: recipe)
        switch item {
        case let .base(baseItem):
            mainStore.warehouse.add(item: baseItem)
            
            mainStore.statistics.itemsCreated += 1
            mainStore.statistics.itemsDestroyed += Int64(recipe.items.count)
            
            self.createdItem = baseItem
        case let .artifact(artifact):
            mainStore.warehouse.add(artifact: artifact)
        }
    }
    
    func showRecipes() {
        coordinator?.push(MainPath.recipeList)
    }
    
}
