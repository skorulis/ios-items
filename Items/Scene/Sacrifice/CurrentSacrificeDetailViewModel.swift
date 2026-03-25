// Created by Alexander Skorulis on 9/3/2026.

import ASKCore
import Combine
import Knit
import KnitMacros
import Foundation
import SwiftUI

@Observable
final class CurrentSacrificeDetailViewModel: SacrificeDetailViewModel {

    private let sacrificeService: SacrificeService
    private let itemGeneratorService: ItemGeneratorService

    var model: SacrificeDetailView.Model = .init(
        plan: .init(itemsInOrder: []),
        qualityChances: [],
        essenceBonuses: [],
        multipleItemsChancePercent: 0
    )

    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(
        sacrificeService: SacrificeService,
        itemGeneratorService: ItemGeneratorService,
        mainStore: MainStore,
    ) {
        self.sacrificeService = sacrificeService
        self.itemGeneratorService = itemGeneratorService

        self.model = makeModel()

        mainStore.$warehouse.delayedChange().sink { [unowned self] _ in
            self.model = self.makeModel()
        }
        .store(in: &cancellables)
    }

    private func makeModel() -> SacrificeDetailView.Model {
        let plan = sacrificeService.sacrificeConsumptionPlan()
        let info = itemGeneratorService.sacrificeInfo(plan: plan)
        let qualityChances = Self.normalizedQualityChances(from: info.quality)
        let essenceBonuses = Self.sortedEssenceBonuses(from: info.essenceBoosts)
        let multipleItemsChancePercent = itemGeneratorService.multipleItemsChancePercent()
        return SacrificeDetailView.Model(
            plan: plan,
            qualityChances: qualityChances,
            essenceBonuses: essenceBonuses,
            multipleItemsChancePercent: multipleItemsChancePercent
        )
    }
}
