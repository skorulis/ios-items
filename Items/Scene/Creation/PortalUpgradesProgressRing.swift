//Created by Alexander Skorulis on 12/3/2026.

import SwiftUI

// MARK: - Portal upgrades progress ring

/// Arc from top, clockwise; `animatableData` makes progress changes interpolate smoothly.
private struct PortalRingProgressArc: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard progress > 0 else { return path }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = Angle.degrees(-90)
        let end = Angle.degrees(-90 + 360 * Double(progress))
        path.addArc(center: center, radius: radius, startAngle: start, endAngle: end, clockwise: false)
        return path
    }
}

/// Same footprint as `PortalCornerButton`; shows a circular ring filled by `amount` (0...1).
struct PortalUpgradesProgressRing: View {
    var amount: CGFloat

    private let size: CGFloat = 44
    private let lineWidth: CGFloat = 4

    @State private var ringOpacity: Double = 0

    private var clampedAmount: CGFloat {
        min(1, max(0, amount))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor.opacity(0.25), lineWidth: lineWidth)
            PortalRingProgressArc(progress: clampedAmount)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round),
                )
        }
        .frame(width: size, height: size)
        .opacity(ringOpacity)
        .accessibilityLabel(Text("Upgrades"))
        .accessibilityValue(Text("\(Int(clampedAmount * 100)) percent"))
        .animation(.easeInOut(duration: 0.45), value: clampedAmount)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) {
                ringOpacity = 1
            }
        }
    }
}
