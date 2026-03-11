//Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Models

/// Fixed five slots for sacrifice layout (pentagram vertices). Slot index 0 = top, then clockwise.
struct SacrificeConfig: Codable, Equatable {
    
    static let slotCount: Int = 5

    /// Exactly `slotCount` elements; `nil` means empty slot.
    var slots: [Int: BaseItem]

    init(slots: [Int: BaseItem] = [:]) {
        self.slots = slots
    }

    func item(at index: Int) -> BaseItem? {
        return slots[index]
    }

    /// Ordered list of assigned items (no nils); order follows slot index 0...4.
    var assignedItems: [BaseItem] {
        return (0..<Self.slotCount).compactMap { slots[$0] }
    }

    mutating func setSlot(index: Int, item: BaseItem?) {
        guard index >= 0, index < Self.slotCount else { return }
        slots[index] = item
    }
}
