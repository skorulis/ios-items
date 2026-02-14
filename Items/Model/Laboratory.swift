//Created by Alexander Skorulis on 13/2/2026.

import Foundation

struct Laboratory: Codable {
    private var items: [BaseItem: Research] = [:]
    
    func research(item: BaseItem) -> Research {
        return items[item] ?? Research()
    }
    
    func currentLevel(item: BaseItem) -> Int {
        return research(item: item).level
    }
    
    mutating func set(research: Research, item: BaseItem) {
        items[item] = research
    }
}
