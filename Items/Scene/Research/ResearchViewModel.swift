//Created by Alexander Skorulis on 13/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ResearchViewModel {
    
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    var selectedItem: BaseItem?
    var showingPicker: Bool = false
    
    private let researchService: ResearchService
    private let calulations: CalculationsService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, researchService: ResearchService, calulations: CalculationsService) {
        self.researchService = researchService
        self.calulations = calulations
        
        
        self.warehouse = mainStore.warehouse
        self.lab = mainStore.lab
        
        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)
        
        mainStore.$lab.sink { [unowned self] in
            self.lab = $0
        }
        .store(in: &cancellables)
        
    }
}

// MARK: - Logic

extension ResearchViewModel {
    
    var canStart: Bool {
        guard let selectedItem else { return false }
        return warehouse.quantity(selectedItem) > 0
    }
    
    func select(item: BaseItem) {
        self.selectedItem = item
    }
    
    func research() {
        guard let selectedItem else { return }
        
        researchService.research(item: selectedItem)
        
    }
    
    var currentLevel: Int {
        guard let selectedItem else { return 0 }
        return lab.currentLevel(item: selectedItem)
    }
    
    var chance: Double {
        let level = self.currentLevel
        let mult = pow(1.5, Double(level))
        
        return calulations.baseResearchChance / mult
    }
    
    
}
