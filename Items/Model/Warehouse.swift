//Created by Alexander Skorulis on 10/2/2026.

import Foundation

struct Warehouse: Codable {
    // Current item storage
    private var current: [BaseItem: Int] = [:]
    
    // Discovered artifacts
    private var artifacts: [Artifact: ItemQuality] = [:]
    
    // Total items that have been found
    private var total: [BaseItem: Int] = [:]
    
    mutating func add(item: BaseItem) {
        current[item, default: 0] += 1
        total[item, default: 0] += 1
    }
    
    mutating func remove(item: BaseItem, quantity: Int = 1) {
        let count = current[item] ?? 0
        current[item] = count - quantity
    }
    
    func quantity(_ item: BaseItem) -> Int {
        return current[item] ?? 0
    }
    
    func hasDiscovered(_ item: BaseItem) -> Bool {
        return total[item] != nil
    }
    
    var totalItemsCollected: Int {
        return total.reduce(0) { $0 + $1.value }
    }
}
