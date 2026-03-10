//Created by Alexander Skorulis on 16/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class ItemDetailsViewModel {
    
    var model: ItemDetailsView.Model
    
    private let mainStore: MainStore
    private let calculations: CalculationsService
    private let warehouseService: WarehouseService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(@Argument item: BaseItem, mainStore: MainStore, calculations: CalculationsService, warehouseService: WarehouseService) {
        self.mainStore = mainStore
        self.calculations = calculations
        self.warehouseService = warehouseService
        
        model = .init(
            item: item,
            lab: mainStore.lab,
            warehouse: mainStore.warehouse,
            details: warehouseService.details(item: item),
        )
        
        mainStore.$lab.sink { [unowned self] in
            self.model.lab = $0
            self.model.details = warehouseService.details(item: item)
        }
        .store(in: &cancellables)
        
        mainStore.$warehouse.sink { [unowned self] in
            self.model.warehouse = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ItemDetailsViewModel {
    
    private var nextArtifactQuality: ItemQuality? {
        guard let type = model.item.associatedArtifact else { return nil }
        return model.warehouse.nextArtifactQuality(artifact: type)
    }

    var nextLevelArtifactChanceString: String? {
        guard let nextQuality = nextArtifactQuality else { return nil }
        let researchLevel = model.details.researchLevel ?? 0
        let chance = calculations.artifactChance(quality: nextQuality, researchLevel: researchLevel)
        let value = chance.percentageString(decimalPlaces: 1)
        if nextQuality == .junk {
            return "Discovery chance \(value)"
        } else {
            return "Upgrade chance: \(value)"
        }
    }
    
    func markItemViewed() {
        warehouseService.markItemViewed(model.item)
    }
}
