//Created by Alexander Skorulis on 10/2/2026.

import Foundation

struct Warehouse {
    var baseItems: [BaseItem: Int] = [:]
    
    mutating func add(item: BaseItem) {
        let count = baseItems[item] ?? 0
        baseItems[item] = count + 1
    }
    
    func quantity(_ item: BaseItem) -> Int {
        return baseItems[item] ?? 0
    }
}
