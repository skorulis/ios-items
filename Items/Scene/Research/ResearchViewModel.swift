//Created by Alexander Skorulis on 13/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ResearchViewModel {
    
    var warehouse: Warehouse
    var selectedItem: BaseItem?
    var showingPicker: Bool = false
    
    private let researchService: ResearchService
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, researchService: ResearchService) {
        self.researchService = researchService
        
        self.warehouse = mainStore.warehouse
        
        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ResearchViewModel {
    
    var canStart: Bool {
        guard let selectedItem else { return false }
        return warehouse.quantity(selectedItem) > 0 && progress.missing.level > 0
    }
    
    func select(item: BaseItem) {
        self.selectedItem = item
    }
    
    func research() {
        guard let selectedItem else { return }
        
        researchService.research(item: selectedItem)
        
    }
    
    var progress: ResearchProgress {
        guard let selectedItem else { return .init(total: .init(), current: .init()) }
        return ResearchProgress(
            total: selectedItem.availableResearch,
            current: researchService.currentResearch(item: selectedItem)
        )
    }
    
    
}
