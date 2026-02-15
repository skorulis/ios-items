//Created by Alexander Skorulis on 13/2/2026.

import Foundation

struct Laboratory: Codable {
    // Current research level
    private var items: [BaseItem: Int] = [:]
    
    func currentLevel(item: BaseItem) -> Int {
        return items[item, default: 0]
    }
    
    mutating func set(level: Int, item: BaseItem) {
        items[item] = level
    }
}
