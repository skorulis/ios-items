//Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Models

/// Result of resolving which warehouse items would be consumed per sacrifice slot.
/// Wraps the per-slot resolution; same item in multiple slots may yield `nil` when stock runs out.
struct SacrificePlan: Equatable {

    /// Slot index → item that would be consumed, or `nil` if the slot is empty or insufficient stock.
    private let slotsByIndex: [Int: BaseItem?]

    init(slotsByIndex: [Int: BaseItem?]) {
        self.slotsByIndex = slotsByIndex
    }

    /// Builds a plan from an ordered list (e.g. legacy recipe items). Indices are 0, 1, 2, …
    init(itemsInOrder items: [BaseItem]) {
        var d: [Int: BaseItem?] = [:]
        for (i, item) in items.enumerated() {
            d[i] = item
        }
        self.slotsByIndex = d
    }

    /// Items that would be consumed, in ascending slot index order (skips unsatisfied / empty slots).
    var consumedItems: [BaseItem] {
        var out: [BaseItem] = []
        for k in slotsByIndex.keys.sorted() {
            if let wrapped = slotsByIndex[k], let item = wrapped {
                out.append(item)
            }
        }
        return out
    }

    /// Item consumable from this slot after accounting for earlier slots, or `nil`.
    func item(at index: Int) -> BaseItem? {
        slotsByIndex[index] ?? nil
    }

    /// `true` when this slot successfully reserves a unit (green border in UI).
    func isSatisfied(at index: Int) -> Bool {
        item(at: index) != nil
    }
    
    func count(quality: ItemQuality) -> Int {
        consumedItems.filter { $0.quality == quality }.count
    }
}
