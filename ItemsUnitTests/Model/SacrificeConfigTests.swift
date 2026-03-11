//Created by Alexander Skorulis on 11/3/2026.

import Models
import XCTest
@testable import Items

final class SacrificeConfigTests: XCTestCase {

    func testBasicSlots() {
        let config = SacrificeConfig(slots: [0: .apple])
        XCTAssertEqual(config.slots[0], .apple)
        XCTAssertNil(config.slots[1])
    }

    func testSetSlot() {
        var config = SacrificeConfig()
        config.setSlot(index: 2, item: .gear)
        XCTAssertEqual(config.item(at: 2), .gear)
        config.setSlot(index: 2, item: nil)
        XCTAssertNil(config.item(at: 2))
    }

    func testAssignedItemsOrder() {
        var config = SacrificeConfig()
        config.setSlot(index: 0, item: .apple)
        config.setSlot(index: 4, item: .rock)
        XCTAssertEqual(config.assignedItems, [.apple, .rock])
    }
}
