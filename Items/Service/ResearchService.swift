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
        
        var existing = mainStore.lab.research(item: item)
        let missing = item.availableResearch.missing(research: existing)
        guard let type = missing.remainingTypes.randomElement() else {
            return
        }
        
        // Research consumes 1 item
        mainStore.warehouse.remove(item: item)
        
        switch type {
        case .essence:
            let found = missing.essences.randomElement()!
            existing.essences.insert(found)
        case .lore:
            existing.lore += 1
        }
        
        mainStore.lab.set(research: existing, item: item)
    }
    
    
}

private enum ResearchType {
    case essence, lore
}

private extension Research {
    var remainingTypes: [ResearchType] {
        var result: [ResearchType] = []
        if essences.count > 0 {
            result.append(.essence)
        }
        if lore > 0 {
            result.append(.lore)
        }
        
        return result
    }
}

extension BaseItem {
    
    // The total research that can be done for the item
    var availableResearch: Research {
        return .init(
            essences: Set(self.essences),
            lore: lore.count,
        )
    }
}
