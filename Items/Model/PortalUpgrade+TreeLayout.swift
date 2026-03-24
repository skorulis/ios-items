// Created by Cursor on 24/3/2026.

import CoreGraphics
import Foundation
import Models

/// Manual layout on an integer **grid**; render positions use `gridSpacing` points per step.
/// `portalUnlocked` is at grid origin; other nodes may use negative X and/or Y.
/// `center(for:)` applies a normalization offset at render time so the tree fits in a positive `ZStack` frame.
enum PortalUpgradeTreeLayout {

    static let nodeSize: CGFloat = 54

    /// Points per integer grid step when converting layout to render coordinates.
    static let gridSpacing: CGFloat = 10

    /// Padding beyond the outermost node edges after normalization.
    private static let canvasMargin: CGFloat = 24

    // swiftlint:disable cyclomatic_complexity function_body_length
    /// Integer grid cell for each upgrade. `portalUnlocked` is always `(0, 0)`; peers may use negative X and/or Y (e.g. above the hub).
    private static func gridPosition(for upgrade: PortalUpgrade) -> (x: Int, y: Int) {
        switch upgrade {
        case .portalUnlocked:
            return (0, 0)
        // First ring: mix of negative and positive Y around the hub.
        case .portalAutomation:
            return (-30, -5)
        case .researchLab:
            return (-12, -14)
        case .sacrifices:
            return (12, -14)
        case .artifactSlot:
            return (30, -5)
        // Knowledge siphon branches from researchLab (see `treeParent`).
        case .knowledgeSiphon:
            return (-26, -20)
        case .mapLocations:
            return (12, 14)
        case .golems:
            return (-12, 14)
        case .researchLabLevel2:
            return (-12, -26)
        case .sacrificesLevel2:
            return (12, -26)
        case .sacrificesLevel3:
            return (12, -38)
        case .sacrificesLevel4:
            return (12, -50)
        case .sacrificesLevel5:
            return (12, -62)
        case .artifactSlotLevel2:
            return (30, -17)
        case .artifactSlotLevel3:
            return (30, -29)
        case .knowledgeSiphonLevel2:
            return (-34, -28)
        case .knowledgeSiphonLevel3:
            return (-42, -36)
        case .knowledgeSiphonLevel4:
            return (-50, -44)
        case .knowledgeSiphonLevel5:
            return (-58, -52)
        case .offlineProgress:
            return (-44, -5)
        case .offlineProgressLevel2:
            return (-58, -5)
        case .offlineProgressLevel3:
            return (-72, -5)
        case .offlineProgressLevel4:
            return (-86, -5)
        case .offlineProgressLevel5:
            return (-100, -5)
        case .tradingPost:
            return (12, 26)
        case .tradingPostLevel2:
            return (12, 38)
        case .tradingPostLevel3:
            return (12, 50)
        case .golemMissionSlotsLevel2:
            return (-12, 26)
        case .golemMissionSlotsLevel3:
            return (-12, 38)
        case .golemMissionSlotsLevel4:
            return (-12, 50)
        case .golemMissionSlotsLevel5:
            return (-12, 62)
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    /// Logical center in points: grid position × `gridSpacing`.
    static func absoluteCenter(for upgrade: PortalUpgrade) -> CGPoint {
        let grid = gridPosition(for: upgrade)
        return CGPoint(x: CGFloat(grid.x) * gridSpacing, y: CGFloat(grid.y) * gridSpacing)
    }

    private static let renderingMetrics: (offset: CGPoint, size: CGSize) = {
        let half = nodeSize / 2
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude
        for upgrade in PortalUpgrade.allCases {
            let point = absoluteCenter(for: upgrade)
            minX = min(minX, point.x - half)
            minY = min(minY, point.y - half)
            maxX = max(maxX, point.x + half)
            maxY = max(maxY, point.y + half)
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
        let normOffset = renderingMetrics.offset
        return CGPoint(x: logical.x + normOffset.x, y: logical.y + normOffset.y)
    }

    static var canvasSize: CGSize {
        renderingMetrics.size
    }

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
