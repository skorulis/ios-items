import Testing
@testable import Models

@Test func portalUpgrade_tree_reaches_root_without_cycles() {
    for upgrade in PortalUpgrade.allCases {
        var steps = 0
        var current = upgrade
        while let parent = current.treeParent {
            current = parent
            steps += 1
            #expect(steps < PortalUpgrade.allCases.count)
        }
        #expect(current == .portalUnlocked)
    }
}
