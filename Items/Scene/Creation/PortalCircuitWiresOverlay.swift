//Created by Alexander Skorulis on 12/3/2026.

import SwiftUI

// MARK: - Portal circuit wires overlay

/// Draws curved "circuit" traces from each **source frame's center** toward the portal center (arc-style, no sharp 90°).
/// Portal center is the center of the overlay (portal art is centered in the square `PortalView`).
/// Frames are in global space unless `useLocalCoordinates` is true; overlay converts using its geometry frame in global.
struct PortalCircuitWiresOverlay: View {

    /// Frames for controls to connect; a wire is drawn from the center of each non-empty rect.
    let sourceFrames: [CGRect]
    /// When true, `sourceFrames` are already in overlay-local space (e.g. previews).
    var useLocalCoordinates: Bool = false

    /// Thick stroke so round-cap “dots” read as circles along the wire.
    private let lineWidth: CGFloat = 7
    private let glowWidth: CGFloat = 14
    /// Gap between circle dots (dot length == lineWidth so caps form discs).
    private let dotGap: CGFloat = 18
    /// One repeat = one dot + gap; phase animates seamlessly over this period.
    private var dashPeriod: CGFloat { lineWidth + dotGap }
    /// Pattern: short segment with round caps reads as a circle; gap separates dots.
    private var dotDashPattern: [CGFloat] { [lineWidth, dotGap] }

    /// One full phase cycle every 2s (matches previous animation duration). Time-based so
    /// recreating the view never stacks multiple `repeatForever` animations on `dashPhase`.
    private let phaseCycleDuration: TimeInterval = 2

    private var activeFrames: [CGRect] {
        sourceFrames.filter { $0.width > 0 && $0.height > 0 }
    }

    var body: some View {
        // Drive dash phase from wall-clock time so conditional show/hide never stacks
        // competing repeatForever animations on the same @State.
        TimelineView(.animation(minimumInterval: 1 / 60, paused: false)) { context in
            let dashPhase = phase(at: context.date)

            GeometryReader { geo in
                let portalCenter = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                ZStack {
                    // Soft glow under traces
                    circuitPath(portalCenter: portalCenter, in: geo)
                        .stroke(
                            Color.accentColor.opacity(0.35),
                            style: StrokeStyle(lineWidth: glowWidth, lineCap: .round, lineJoin: .round)
                        )
                    // Circle dots along the wire — dash length == lineWidth + round caps => discs
                    circuitPath(portalCenter: portalCenter, in: geo)
                        .stroke(
                            Color.accentColor.opacity(0.92),
                            style: StrokeStyle(
                                lineWidth: lineWidth,
                                lineCap: .round,
                                lineJoin: .round,
                                dash: dotDashPattern,
                                dashPhase: dashPhase
                            )
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    /// Same motion as before: phase sweeps from `dashPeriod` down to `0` every `phaseCycleDuration`, repeating.
    private func phase(at date: Date) -> CGFloat {
        let t = date.timeIntervalSinceReferenceDate
        let cycle = phaseCycleDuration
        let u = t.truncatingRemainder(dividingBy: cycle) / cycle // 0..1
        // Previously: animated from dashPeriod → 0 linearly each cycle.
        return dashPeriod * (1 - CGFloat(u))
    }

    private func convert(_ globalRect: CGRect, in geo: GeometryProxy) -> CGRect {
        if useLocalCoordinates { return globalRect }
        let globalGeo = geo.frame(in: .global)
        return CGRect(
            x: globalRect.minX - globalGeo.minX,
            y: globalRect.minY - globalGeo.minY,
            width: globalRect.width,
            height: globalRect.height
        )
    }

    private func circuitPath(portalCenter: CGPoint, in geo: GeometryProxy) -> Path {
        var path = Path()
        for globalRect in activeFrames {
            let local = convert(globalRect, in: geo)
            let start = CGPoint(x: local.midX, y: local.midY)
            appendArcTowardCenter(&path, from: start, to: portalCenter)
        }
        return path
    }

    /// Single smooth arc from corner toward portal center — uses the old elbow as quad control
    /// so the trace sweeps inward instead of a straight+90° bend.
    private func appendArcTowardCenter(_ path: inout Path, from start: CGPoint, to end: CGPoint) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let elbow: CGPoint
        if abs(dx) >= abs(dy) {
            elbow = CGPoint(x: end.x, y: start.y)
        } else {
            elbow = CGPoint(x: start.x, y: end.y)
        }
        path.move(to: start)
        path.addQuadCurve(to: end, control: elbow)
    }
}
