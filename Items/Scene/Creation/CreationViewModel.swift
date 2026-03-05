//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import ASKCore
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class CreationViewModel: CoordinatorViewModel {
    
    private var makeTimer: Timer?
    
    var model = CreationView.Model()
    var coordinator: ASKCoordinator.Coordinator?
    
    var automateCreation: Bool = false {
        didSet {
            if automateCreation {
                startMakeTimer()
            } else {
                stopMakeTimer()
            }
        }
    }

    /// Unique id for the current countdown. Changes each time the timer restarts so the progress view can reset and re-animate.
    private(set) var autoTimerProgress: TimerProgressView.Model?
    
    private let itemGeneratorService: ItemGeneratorService
    private let calculations: CalculationsService
    private let mainStore: MainStore
    private let upgradeService: UpgradeService
    private let recipeService: RecipeService
    private let warehouseService: WarehouseService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(
        itemGeneratorService: ItemGeneratorService,
        mainStore: MainStore,
        recipeService: RecipeService,
        calculations: CalculationsService,
        upgradeService: UpgradeService,
        warehouseService: WarehouseService,
    ) {
        self.itemGeneratorService = itemGeneratorService
        self.mainStore = mainStore
        self.recipeService = recipeService
        self.calculations = calculations
        self.upgradeService = upgradeService
        self.warehouseService = warehouseService
        
        self.model.automationUnlocked = mainStore.portalUpgrades.purchased.contains(.portalAutomation)
        self.model.sacrificesUnlocked = mainStore.portalUpgrades.purchased.contains(.sacrifices)

        mainStore.$warehouse.sink { [unowned self] in
            self.model.warehouse = $0
            self.updateUpgradeBadgeCount()
        }
        .store(in: &cancellables)
        
        mainStore.$portalUpgrades
            .delayedChange()
            .sink { [unowned self] _ in
            self.updateUpgradeBadgeCount()
        }
        .store(in: &cancellables)

        mainStore.$recipes.sink { [unowned self] in
            self.model.recipes = $0
        }
        .store(in: &cancellables)

        mainStore.$achievements.sink { [unowned self] in
            self.model.achievements = $0
            self.updateUpgradeBadgeCount()
        }
        .store(in: &cancellables)

        mainStore.$portalUpgrades.sink { [unowned self] in
            self.model.automationUnlocked = $0.purchased.contains(.portalAutomation)
            self.model.sacrificesUnlocked = $0.purchased.contains(.sacrifices)
            self.model.showingResearch = $0.purchased.contains(.researchLab)
            self.updateUpgradeBadgeCount()
        }
        .store(in: &cancellables)

        mainStore.$notifications.sink { [unowned self] in
            self.model.researchBadgeCount = $0.newResearchLevels
        }
        .store(in: &cancellables)

        self.model.showingResearch = mainStore.portalUpgrades.purchased.contains(.researchLab)
        self.model.researchBadgeCount = mainStore.notifications.newResearchLevels
        self.updateUpgradeBadgeCount()
    }
    
    deinit {
        stopMakeTimer()
    }

    private func startMakeTimer() {
        stopMakeTimer()
        let time = calculations.autoCreationMilliseconds / 1000
        
        autoTimerProgress = .init(id: UUID(), duration: time)
        makeTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] _ in
            Task { @MainActor in
                if self?.automateCreation == true {
                    self?.startMakeTimer()
                }
                guard self?.model.creationInProgress == nil else { return }
                await self?.make()
            }
        }
    }

    private func stopMakeTimer() {
        makeTimer?.invalidate()
        makeTimer = nil
        autoTimerProgress = nil
    }

    private func updateUpgradeBadgeCount() {
        model.upgradesBadgeCount = upgradeService.purchasableUpgrades().count
    }
}

// MARK: - Logic

extension CreationViewModel {
    
    func make() async {
        if model.creationInProgress != nil { return }
        let recipe = recipeService.nextAvailable()
        let duration = TimeInterval(calculations.itemCreationMilliseconds) / 1000
        self.model.creationInProgress = CreationView.CreationInProgress(id: UUID(), duration: duration, sacrificedItems: recipe.items)
        self.model.createdItem = nil
        recipeService.consumeRecipe(recipe)
        mainStore.statistics.itemsSacrificed += Int64(recipe.items.count)

        try? await Task.sleep(for: .milliseconds(calculations.itemCreationMilliseconds))
        self.model.creationInProgress = nil
        
        let item = itemGeneratorService.make(recipe: recipe)
        switch item {
        case let .base(baseItem, count):
            warehouseService.add(item: baseItem, count: count)
            
            mainStore.statistics.itemsCreated += Int64(count)
            if count > 1 {
                mainStore.statistics.doubleItemCreations += 1
            }
        case let .artifact(artifact):
            warehouseService.add(artifact: artifact)
        }
        
        self.model.createdItem = item
    }
    
    func showRecipes() {
        coordinator?.push(MainPath.recipeList)
    }

    func showPortalUpgrades() {
        coordinator?.push(MainPath.portalUpgrades)
    }
    
    func showDetails(item: BaseItem) {
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }

    func showResearch() {
        coordinator?.push(MainPath.research)
    }
}
