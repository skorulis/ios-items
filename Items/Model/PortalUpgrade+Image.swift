// Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import SwiftUI

/// App-specific extensions for `PortalUpgrade` that depend on UI or app-only models.
extension PortalUpgrade {

    /// Primary symbol plus a bottom-right badge for tree nodes and other UI.
    var layeredIcon: LayeredIcon {
        switch self {
        case .portalUnlocked:
            return makeLayeredIcon(main: "lock.open.fill")
        case .portalAutomation:
            return makeLayeredIcon(main: "play.circle.fill")
        case .portalAutomationLevel2:
            return makeLayeredIcon(main: "play.circle.fill", overlay: "2.circle.fill")
        case .portalAutomationLevel3:
            return makeLayeredIcon(main: "play.circle.fill", overlay: "3.circle.fill")
        case .portalAutomationLevel4:
            return makeLayeredIcon(main: "play.circle.fill", overlay: "4.circle.fill")
        case .portalAutomationLevel5:
            return makeLayeredIcon(main: "play.circle.fill", overlay: "5.circle.fill")
        case .portalDuplication:
            return makeLayeredIcon(main: "doc.on.doc.fill")
        case .portalDuplicationLevel2:
            return makeLayeredIcon(main: "doc.on.doc.fill", overlay: "2.circle.fill")
        case .portalDuplicationLevel3:
            return makeLayeredIcon(main: "doc.on.doc.fill", overlay: "3.circle.fill")
        case .portalDuplicationLevel4:
            return makeLayeredIcon(main: "doc.on.doc.fill", overlay: "4.circle.fill")
        case .portalDuplicationLevel5:
            return makeLayeredIcon(main: "doc.on.doc.fill", overlay: "5.circle.fill")
        case .researchLab:
            return makeLayeredIcon(main: "flask.fill")
        case .researchLabLevel2:
            return makeLayeredIcon(main: "flask.fill", overlay: "2.circle.fill")
        case .researchLabLevel3:
            return makeLayeredIcon(main: "flask.fill", overlay: "3.circle.fill")
        case .researchLabLevel4:
            return makeLayeredIcon(main: "flask.fill", overlay: "4.circle.fill")
        case .researchLabLevel5:
            return makeLayeredIcon(main: "flask.fill", overlay: "5.circle.fill")
        case .sacrifices:
            return makeLayeredIcon(main: "flame.fill")
        case .sacrificesLevel2:
            return makeLayeredIcon(main: "flame.fill", overlay: "2.circle.fill")
        case .sacrificesLevel3:
            return makeLayeredIcon(main: "flame.fill", overlay: "3.circle.fill")
        case .sacrificesLevel4:
            return makeLayeredIcon(main: "flame.fill", overlay: "4.circle.fill")
        case .sacrificesLevel5:
            return makeLayeredIcon(main: "flame.fill", overlay: "5.circle.fill")
        case .sacrificesPower:
            return makeLayeredIcon(main: "bolt.fill")
        case .sacrificesPowerLevel2:
            return makeLayeredIcon(main: "bolt.fill", overlay: "2.circle.fill")
        case .sacrificesPowerLevel3:
            return makeLayeredIcon(main: "bolt.fill", overlay: "3.circle.fill")
        case .sacrificesPowerLevel4:
            return makeLayeredIcon(main: "bolt.fill", overlay: "4.circle.fill")
        case .sacrificesPowerLevel5:
            return makeLayeredIcon(main: "bolt.fill", overlay: "5.circle.fill")
        case .artifactSlot:
            return makeLayeredIcon(main: "square.stack.3d.up.fill")
        case .artifactSlotLevel2:
            return makeLayeredIcon(main: "square.stack.3d.up.fill", overlay: "2.circle.fill")
        case .artifactSlotLevel3:
            return makeLayeredIcon(main: "square.stack.3d.up.fill", overlay: "3.circle.fill")
        case .knowledgeSiphon:
            return makeLayeredIcon(main: "book.fill")
        case .knowledgeSiphonLevel2:
            return makeLayeredIcon(main: "book.fill", overlay: "2.circle.fill")
        case .knowledgeSiphonLevel3:
            return makeLayeredIcon(main: "book.fill", overlay: "3.circle.fill")
        case .knowledgeSiphonLevel4:
            return makeLayeredIcon(main: "book.fill", overlay: "4.circle.fill")
        case .knowledgeSiphonLevel5:
            return makeLayeredIcon(main: "book.fill", overlay: "5.circle.fill")
        case .offlineProgress:
            return makeLayeredIcon(main: "arrow.up.circle.badge.clock")
        case .offlineProgressLevel2:
            return makeLayeredIcon(main: "arrow.up.circle.badge.clock", overlay: "2.circle.fill")
        case .offlineProgressLevel3:
            return makeLayeredIcon(main: "arrow.up.circle.badge.clock", overlay: "3.circle.fill")
        case .offlineProgressLevel4:
            return makeLayeredIcon(main: "arrow.up.circle.badge.clock", overlay: "4.circle.fill")
        case .offlineProgressLevel5:
            return makeLayeredIcon(main: "arrow.up.circle.badge.clock", overlay: "5.circle.fill")
        case .mapLocations:
            return makeLayeredIcon(main: "map.fill", overlay: "mappin.circle.fill")
        case .tradingPost:
            return makeLayeredIcon(main: "storefront")
        case .tradingPostLevel2:
            return makeLayeredIcon(main: "storefront", overlay: "2.circle.fill")
        case .tradingPostLevel3:
            return makeLayeredIcon(main: "storefront", overlay: "3.circle.fill")
        case .golems:
            return makeLayeredIcon(main: "person.3.fill")
        case .golemMissionSlotsLevel2:
            return makeLayeredIcon(main: "person.3.fill", overlay: "2.circle.fill")
        case .golemMissionSlotsLevel3:
            return makeLayeredIcon(main: "person.3.fill", overlay: "3.circle.fill")
        case .golemMissionSlotsLevel4:
            return makeLayeredIcon(main: "person.3.fill", overlay: "4.circle.fill")
        case .golemMissionSlotsLevel5:
            return makeLayeredIcon(main: "person.3.fill", overlay: "5.circle.fill")
        }
    }

    private func makeLayeredIcon(main: String, overlay: String? = nil) -> LayeredIcon {
        LayeredIcon(main: Image(systemName: main), overlay: overlay.map { Image(systemName: $0) })
    }
}
