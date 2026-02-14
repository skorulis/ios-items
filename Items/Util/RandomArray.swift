//Created by Alexander Skorulis on 14/2/2026.

import Foundation

struct RandomArray<ItemType> {
    
    private var store: [Wrapper]
    private let total: Double
    
    init(items: [ItemType], score: (ItemType) -> Double) {
        var total: Double = 0
        var temp: [Wrapper] = []
        for item in items {
            let s = score(item)
            if s <= 0 {
                continue
            }
            let range = total..<(s + total)
            temp.append(.init(item: item, range: range))
            total += s
        }
        
        self.store = temp
        self.total = total
    }
    
    var maxValue: Double {
        return store.last?.range.upperBound ?? 0
    }
    
    var random: ItemType? {
        return randomWithIndex?.0
    }
    
    var randomWithIndex: (ItemType, Int)? {
        if store.isEmpty {
            return nil
        }
        for _ in 0..<10 {
            let number = Double.random(in: 0..<maxValue)
            if let value = find(value: number, range: 0..<store.count) {
                return value
            }
        }
        return nil
    }
    
    func find(value: Double, range: Range<Int>) -> (ItemType, Int)? {
        let index = (range.lowerBound + range.upperBound) / 2
        let item = store[index]
        if item.range.lowerBound > value {
            return find(value: value, range: range.lowerBound..<index)
        } else if item.range.upperBound < value {
            return find(value: value, range: index+1..<range.upperBound)
        } else {
            return (item.item, index)
        }
    }
    
    func firstIndex(where predicate: (ItemType) throws -> Bool) rethrows -> Int? {
        return try allItems.firstIndex(where: predicate)
    }
    
    var count: Int {
        return store.count
    }
    
    var allItems: [ItemType] {
        return store.map { $0.item }
    }
    
}

extension RandomArray where ItemType: Identifiable {
    
    // Replace an item in the store without updating the random access values
    mutating func replace(item: ItemType) {
        guard let index = store.firstIndex(where: {$0.item.id == item.id}) else {
            fatalError("Tried to replace an item which did not exist \(item)")
        }
        let wrapper = store[index]
        self.store[index] = Wrapper(item: item, range: wrapper.range)
    }
    
    mutating func maybeReplace(item: ItemType) {
        guard let index = store.firstIndex(where: {$0.item.id == item.id}) else {
            return
        }
        let wrapper = store[index]
        self.store[index] = Wrapper(item: item, range: wrapper.range)
    }
}

private extension RandomArray {
    
    struct Wrapper {
        let item: ItemType
        let range: Range<Double>
    }
    
}
