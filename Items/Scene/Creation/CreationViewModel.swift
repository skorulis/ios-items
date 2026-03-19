// Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import ASKCore
import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class CreationViewModel: CoordinatorViewModel {

    private var makeTimer: Timer?

    var model = CreationView.Model()
    weak var coordinator: ASKCoordinator.Coordinator?

    @ObservationIgnored var upgradeButtonFrame: CGRect = .zero
    @ObservationIgnored var researchButtonFrame: CGRect = .zero
    @ObservationIgnored var sacrificesButtonFrame: CGRect = .zero
    @ObservationIgnored var mapLocationButtonFrame: CGRect = .zero

    var automateCreation: Bool = false {
        didSet {
            mainStore.offlineState = OfflineState(
                lastBackgroundedAt: mainStore.offlineState.lastBackgroundedAt,
                automationEnabled: automateCreation
            )
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

        self.automateCreation = mainStore.offlineState.automationEnabled

        mainStore.$warehouse.sink { [unowned self] in
            self.model.warehouse = $0
        }
        .store(in: &cancellables)

        mainStore.$mapLocations.sink { [unowned self] in
            self.model.mapLocations = $0
        }
        .store(in: &cancellables)

        recipeService.$sacrificePlan.sink { [unowned self] plan in
            self.model.sacrificePlan = plan
        }
        .store(in: &cancellables)

        upgradeService.$purchasableUpgrades.sink { [unowned self] newValue in
            self.model.upgradesBadgeCount = newValue.count
        }
        .store(in: &cancellables)

        mainStore.$achievements.sink { [unowned self] in
            self.model.achievements = $0
        }
        .store(in: &cancellables)

        mainStore.$statistics.sink { [unowned self] in
            self.model.itemsCreatedCount = $0.itemsCreated
        }
        .store(in: &cancellables)

        mainStore.$portalUpgrades.sink { [unowned self] in
            self.model.automationUnlocked = $0.purchased.contains(.portalAutomation)
            self.model.sacrificesUnlocked = $0.purchased.contains(.sacrifices)
            self.model.showingResearch = $0.purchased.contains(.researchLab)
            self.model.mapLocationsUnlocked = $0.purchased.contains(.mapLocations)
        }
        .store(in: &cancellables)

        mainStore.$lab.sink { [unowned self] in
            self.model.researchUnderway = $0.currentResearch != nil
        }
        .store(in: &cancellables)

        mainStore.$notifications.sink { [unowned self] in
            self.model.researchBadgeCount = $0.newResearchLevels
        }
        .store(in: &cancellables)

        calculations.$maxArtifactSlots.sink { [unowned self] in
            self.model.maxArtifacts = $0
        }
        .store(in: &cancellables)

        mainStore.$recipes.sink { [unowned self] in
            self.model.sacrificeConfig = $0.sacrificeConfig
        }
        .store(in: &cancellables)
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
}

// MARK: - Logic

extension CreationViewModel {

    func make() async {
        if model.creationInProgress != nil { return }
        let plan = recipeService.sacrificePlan
        let consumed = plan.consumedItems
        let duration = TimeInterval(calculations.itemCreationMilliseconds) / 1000
        self.model.creationInProgress = CreationView.CreationInProgress(
            id: UUID(),
            duration: duration,
            sacrificedItems: consumed,
        )
        self.model.createdItems = []
        recipeService.consumePlan(plan)
        mainStore.statistics.itemsSacrificed += Int64(consumed.count)

        try? await Task.sleep(for: .milliseconds(calculations.itemCreationMilliseconds))
        self.model.creationInProgress = nil

        self.model.createdItems = itemGeneratorService.makeAndStore(plan: plan)
        mainStore.offlineState.updateBackgroundedTime()
    }

    func showRecipes() {
        let path = CircularAnimationPath(sourceRect: sacrificesButtonFrame, mainPath: .sacrifices)
        coordinator?.custom(overlay: .circularReveal, path)
    }

    func showCurrentRecipeDetail() {
        coordinator?.custom(overlay: .card, MainPath.currentRecipeDetail)
    }

    func showPortalUpgrades() {
        let path = CircularAnimationPath(sourceRect: upgradeButtonFrame, mainPath: .portalUpgrades)
        coordinator?.custom(overlay: .circularReveal, path)
    }

    func showDetails(item: MakeItemResult) {
        switch item {
        case let .base(item, _):
            coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
        case let .artifact(artifact):
            coordinator?.custom(overlay: .card, MainPath.artifactDetails(artifact))
        }
    }

    func showResearch() {
        let path = CircularAnimationPath(sourceRect: researchButtonFrame, mainPath: .research)
        coordinator?.custom(overlay: .circularReveal, path)
    }

    func showMapLocations() {
        let path = CircularAnimationPath(sourceRect: mapLocationButtonFrame, mainPath: .mapLocations)
        coordinator?.custom(overlay: .circularReveal, path)
    }

    func showUpgradesProgressHelp() {
        let text = "Summon 10 items to unlock upgrades"
        coordinator?.custom(overlay: .card, MainPath.dialog(text))
    }

    func artifactSlotPressed(index: Int) {
        let slotContents = mainStore.warehouse.equippedSlotsContents(upToSlotCount: model.maxArtifacts)
        guard index < slotContents.count else { return }
        coordinator?.custom(overlay: .card, MainPath.artifactPicker(slot: index))
    }
}
