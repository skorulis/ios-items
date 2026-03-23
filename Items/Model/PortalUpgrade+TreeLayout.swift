// Created by Cursor on 24/3/2026.

import CoreGraphics
import Foundation
import Models

/// Manual layout in **logical** space: `portalUnlocked` at the origin; other nodes may use negative X and/or Y.
/// `center(for:)` applies a normalization offset at render time so the tree fits in a positive `ZStack` frame.
enum PortalUpgradeTreeLayout {

    static let nodeSize: CGFloat = 54

    /// Padding beyond the outermost node edges after normalization.
    private static let canvasMargin: CGFloat = 24

    // swiftlint:disable cyclomatic_complexity function_body_length
    /// Logical center for each upgrade. `portalUnlocked` is always `(0, 0)`; peers may use negative X and/or Y (e.g. above the hub).
    static func absoluteCenter(for upgrade: PortalUpgrade) -> CGPoint {
        switch upgrade {
        case .portalUnlocked:
            return .zero
        // First ring: mix of negative and positive Y around the hub.
        case .portalAutomation:
            return CGPoint(x: -300, y: -50)
        case .researchLab:
            return CGPoint(x: -120, y: -140)
        case .sacrifices:
            return CGPoint(x: 120, y: -140)
        case .artifactSlot:
            return CGPoint(x: 300, y: -50)
        case .knowledgeSiphon:
            return CGPoint(x: 300, y: 80)
        case .mapLocations:
            return CGPoint(x: 120, y: 140)
        case .golems:
            return CGPoint(x: -120, y: 140)
        case .researchLabLevel2:
            return CGPoint(x: -120, y: -260)
        case .sacrificesLevel2:
            return CGPoint(x: 120, y: -260)
        case .sacrificesLevel3:
            return CGPoint(x: 120, y: -380)
        case .sacrificesLevel4:
            return CGPoint(x: 120, y: -500)
        case .sacrificesLevel5:
            return CGPoint(x: 120, y: -620)
        case .artifactSlotLevel2:
            return CGPoint(x: 300, y: -170)
        case .artifactSlotLevel3:
            return CGPoint(x: 300, y: -290)
        case .knowledgeSiphonLevel2:
            return CGPoint(x: 300, y: 200)
        case .knowledgeSiphonLevel3:
            return CGPoint(x: 300, y: 320)
        case .knowledgeSiphonLevel4:
            return CGPoint(x: 300, y: 440)
        case .knowledgeSiphonLevel5:
            return CGPoint(x: 300, y: 560)
        case .offlineProgress:
            return CGPoint(x: -440, y: -50)
        case .offlineProgressLevel2:
            return CGPoint(x: -580, y: -50)
        case .offlineProgressLevel3:
            return CGPoint(x: -720, y: -50)
        case .offlineProgressLevel4:
            return CGPoint(x: -860, y: -50)
        case .offlineProgressLevel5:
            return CGPoint(x: -1000, y: -50)
        case .tradingPost:
            return CGPoint(x: 120, y: 260)
        case .tradingPostLevel2:
            return CGPoint(x: 120, y: 380)
        case .tradingPostLevel3:
            return CGPoint(x: 120, y: 500)
        case .golemMissionSlotsLevel2:
            return CGPoint(x: -120, y: 260)
        case .golemMissionSlotsLevel3:
            return CGPoint(x: -120, y: 380)
        case .golemMissionSlotsLevel4:
            return CGPoint(x: -120, y: 500)
        case .golemMissionSlotsLevel5:
            return CGPoint(x: -120, y: 620)
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    private static let renderingMetrics: (offset: CGPoint, size: CGSize) = {
        let half = nodeSize / 2
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude
        for upgrade in PortalUpgrade.allCases {
            let p = absoluteCenter(for: upgrade)
            minX = min(minX, p.x - half)
            minY = min(minY, p.y - half)
            maxX = max(maxX, p.x + half)
            maxY = max(maxY, p.y + half)
        }
        let offset = CGPoint(x: canvasMargin - minX, y: canvasMargin - minY)
        let size = CGSize(
            width: maxX - minX + 2 * canvasMargin,
            height: maxY - minY + 2 * canvasMargin
        )
        return (offset, size)
    }()

    /// Normalized position for SwiftUI `.position` in the scroll canvas.
    static func center(for upgrade: PortalUpgrade) -> CGPoint {
        let logical = absoluteCenter(for: upgrade)
        let o = renderingMetrics.offset
        return CGPoint(x: logical.x + o.x, y: logical.y + o.y)
    }

    static var canvasSize: CGSize {
        renderingMetrics.size
    }

    /// Stable id for `ScrollViewReader` — scroll so this view’s bounds land at the viewport center.
    static let scrollCenterViewID = "portalUpgradeTreeHub"

    /// Connection anchors along the line between parent and child (through circle edges), in **normalized** space.
    static func lineEndPoints(parent: PortalUpgrade, child: PortalUpgrade) -> (CGPoint, CGPoint) {
        let half = nodeSize / 2
        let parentCenter = center(for: parent)
        let childCenter = center(for: child)
        let dx = childCenter.x - parentCenter.x
        let dy = childCenter.y - parentCenter.y
        let length = hypot(dx, dy)
        guard length > 0.001 else {
            return (parentCenter, childCenter)
        }
        let ux = dx / length
        let uy = dy / length
        return (
            CGPoint(x: parentCenter.x + ux * half, y: parentCenter.y + uy * half),
            CGPoint(x: childCenter.x - ux * half, y: childCenter.y - uy * half)
        )
    }
}
