//Created by Alexander Skorulis on 13/2/2026.

import Knit
import KnitMacros
import Foundation

final class ResearchService {
    
    private let mainStore: MainStore
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
}

extension ResearchService {
    
    func research(item: BaseItem) {
        // TODO: Add delay and failure chance
        
        guard mainStore.warehouse.quantity(item) > 0 else {
            return
        }
        
        let level = mainStore.lab.currentLevel(item: item)
        
        // Research consumes 1 item
        mainStore.warehouse.remove(item: item)
        
        
        mainStore.lab.set(level: level + 1, item: item)
    }
    
    
}

private enum ResearchType {
    case essence, lore
}

extension BaseItem {
    
    // The total research that can be done for the item
    var availableResearch: Research {
        return .init(
            essences: self.essences,
            artifact: self.associatedArtifact != nil,
            lore: lore,
        )
    }
}
