//Created by Alexander Skorulis on 11/2/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct SacrificeAnimationView {
    private let items: [BaseItem]
    private let startPosition: CGPoint
    private let endPosition: CGPoint
    private let duration: TimeInterval
    private let animationId: UUID

    @State private var progress: Double = 0
    @State private var curveControlPoints: [CGPoint]?

    init(
        items: [BaseItem],
        startPosition: CGPoint,
        endPosition: CGPoint,
        duration: TimeInterval,
        animationId: UUID
    ) {
        self.items = items
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.duration = duration
        self.animationId = animationId
    }
}

// MARK: - Animatable avatar on curve

private struct CurvedPathAvatar: View, Animatable {
    let item: BaseItem
    let start: CGPoint
    let control: CGPoint
    let end: CGPoint
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        let point = quadraticBezier(start, control, end, progress)
        AvatarView(
            text: item.name,
            image: item.image,
            border: item.quality.color,
            size: .small
        )
        .position(x: point.x, y: point.y)
    }

    private func quadraticBezier(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ t: CGFloat) -> CGPoint {
        let u = 1 - t
        let u2 = u * u
        let u1 = 2 * u * t
        let t2 = t * t
        return CGPoint(
            x: u2 * p0.x + u1 * p1.x + t2 * p2.x,
            y: u2 * p0.y + u1 * p1.y + t2 * p2.y
        )
    }
}

// MARK: - Rendering

extension SacrificeAnimationView: View {
    private var defaultControlPoint: CGPoint {
        CGPoint(
            x: (startPosition.x + endPosition.x) / 2,
            y: (startPosition.y + endPosition.y) / 2
        )
    }

    var body: some View {
        TimelineView(.animation) { _ in
            avatars
        }
        .allowsHitTesting(false)
        .task(id: animationId) {
            curveControlPoints = (0 ..< items.count).map { _ in randomControlPoint() }
            progress = 0
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
    
    private var avatars: some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]
                let stagger = CGFloat(index) * 24 - CGFloat(items.count - 1) * 12
                let start = CGPoint(
                    x: startPosition.x + stagger,
                    y: startPosition.y + stagger * 0.5
                )
                let control = curveControlPoints?[index] ?? defaultControlPoint
                CurvedPathAvatar(
                    item: item,
                    start: start,
                    control: control,
                    end: endPosition,
                    progress: CGFloat(progress)
                )
                .opacity(1 - progress)
            }
        }
    }

    private func randomControlPoint() -> CGPoint {
        let mid = CGPoint(
            x: (startPosition.x + endPosition.x) / 2,
            y: (startPosition.y + endPosition.y) / 2
        )
        let dx = endPosition.x - startPosition.x
        let dy = endPosition.y - startPosition.y
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return mid }
        let perpX = -dy / length
        let perpY = dx / length
        let offset = CGFloat.random(in: 40 ... 120) * (Bool.random() ? 1 : -1)
        return CGPoint(
            x: mid.x + perpX * offset,
            y: mid.y + perpY * offset
        )
    }
}

// MARK: - Previews

#Preview {
    struct PreviewWrapper: View {
        @State private var animationId = UUID()
        private let items: [BaseItem] = [.apple, .rock, .gear]

        var body: some View {
            GeometryReader { geo in
                let endPosition = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                ZStack(alignment: .bottom) {
                    SacrificeAnimationView(
                        items: items,
                        startPosition: .zero,
                        endPosition: endPosition,
                        duration: 0.75,
                        animationId: animationId
                    )
                    Button("Trigger animation") {
                        animationId = UUID()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 40)
                }
            }
            .frame(width: 350, height: 500)
        }
    }
    return PreviewWrapper()
}
