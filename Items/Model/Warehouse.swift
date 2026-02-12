//Created by Alexander Skorulis on 10/2/2026.

import Foundation

struct Warehouse {
    var baseItems: [BaseItem: Int] = [:]
    
    mutating func add(item: BaseItem) {
        let count = baseItems[item] ?? 0
        baseItems[item] = count + 1
    }
    
    mutating func remove(item: BaseItem, quantity: Int = 1) {
        let count = baseItems[item] ?? 0
        baseItems[item] = count - quantity
    }
    
    func quantity(_ item: BaseItem) -> Int {
        return baseItems[item] ?? 0
    }
}
