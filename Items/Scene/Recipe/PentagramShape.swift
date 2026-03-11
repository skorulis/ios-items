//Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Layout (shared by star, ring, and slot positions)

enum PentagramLayout {

    /// Default inset from min dimension before radius (matches SacrificeView padding intent).
    static let inset: CGFloat = 24

    static func center(in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.midX, y: rect.midY)
    }

    /// Half of (min side − 2×inset); `inset` defaults to 24 for full-screen pentagram; use a small inset (e.g. 4) for compact buttons.
    static func radius(in rect: CGRect, inset: CGFloat = PentagramLayout.inset) -> CGFloat {
        let size = min(rect.width, rect.height) - inset * 2
        return max(0, size / 2)
    }

    /// Slot / vertex index 0 = top, then clockwise.
    static func vertexPoint(index: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = -CGFloat.pi / 2 + CGFloat(index) * 2 * CGFloat.pi / CGFloat(SacrificeConfig.slotCount)
        return CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
}

// MARK: - Circumcircle

/// Circle through the five pentagram vertices (same center/radius as star).
struct PentagramCircumcircleShape: Shape {
    /// Inset from rect edges before computing radius; smaller = larger pentagram in same rect.
    var layoutInset: CGFloat = PentagramLayout.inset

    func path(in rect: CGRect) -> Path {
        let center = PentagramLayout.center(in: rect)
        let radius = PentagramLayout.radius(in: rect, inset: layoutInset)
        var path = Path()
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        return path
    }
}

// MARK: - Star (curved edges)

/// Pentagram stroke: connect every second vertex (0-2-4-1-3-0) with slight outward curves.
struct PentagramShape: Shape {
    var layoutInset: CGFloat = PentagramLayout.inset

    func path(in rect: CGRect) -> Path {
        let center = PentagramLayout.center(in: rect)
        let radius = PentagramLayout.radius(in: rect, inset: layoutInset)
        let points = (0..<SacrificeConfig.slotCount).map {
            PentagramLayout.vertexPoint(index: $0, center: center, radius: radius)
        }
        let order = [0, 2, 4, 1, 3, 0]
        let bulge = radius * 0.12

        var path = Path()
        path.move(to: points[order[0]])

        for i in 1..<order.count {
            let a = points[order[i - 1]]
            let b = points[order[i]]
            let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
            let vx = mid.x - center.x
            let vy = mid.y - center.y
            let len = sqrt(vx * vx + vy * vy)
            let control: CGPoint
            if len > 1 {
                let ux = vx / len
                let uy = vy / len
                control = CGPoint(x: mid.x + ux * bulge, y: mid.y + uy * bulge)
            } else {
                let abx = b.x - a.x
                let aby = b.y - a.y
                let abLen = sqrt(abx * abx + aby * aby)
                if abLen > 1 {
                    let px = -aby / abLen
                    let py = abx / abLen
                    let dot = (mid.x - center.x) * px + (mid.y - center.y) * py
                    let sign: CGFloat = dot >= 0 ? 1 : -1
                    control = CGPoint(x: mid.x + sign * px * bulge, y: mid.y + sign * py * bulge)
                } else {
                    control = mid
                }
            }
            path.addQuadCurve(to: b, control: control)
        }
        return path
    }
}
