//Created by Alexander Skorulis on 13/2/2026.

import Foundation


// Research that has been done about an item
struct Research {
    var essences: Set<Essence>
    var lore: Int // Number of lore values which have been unlocked
    
    public init(
        essences: Set<Essence> = [],
        lore: Int = 0
    ) {
        self.essences = essences
        self.lore = lore
    }
    
    /// The level of research
    var level: Int {
        return essences.count + lore
    }
    
    // Return what parts of this research are still missing in the given research
    func missing(research: Research) -> Research {
        let lore = max(self.lore - research.lore, 0)
        let essences = self.essences.filter { !research.essences.contains($0) }
        
        return Research(essences: essences, lore: lore)
    }
}

struct ResearchProgress {
    let total: Research
    let current: Research
    
    var missing: Research { total.missing(research: current) }
}
