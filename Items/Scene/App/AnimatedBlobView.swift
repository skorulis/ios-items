import SwiftUI

struct AnimatedBlobView: View {
    @State private var phase: CGFloat = 0
    var color: Color = .blue
    var size: CGFloat = 200
    var speed: Double = 0.6
    var points: Int = 8
    var jitter: CGFloat = 0.25

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let t = CGFloat(time * speed)
            BlobShape(points: points, phase: t, jitter: jitter)
                .fill(
                    RadialGradient(colors: [color.opacity(0.9), color.opacity(0.5), color.opacity(0.2)], center: .center, startRadius: 0, endRadius: size/1.2)
                )
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.35), radius: 20, x: 0, y: 10)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: t)
        }
        .onAppear {
            phase = .pi
        }
    }
}

private struct BlobShape: Shape {
    var points: Int
    var phase: CGFloat
    var jitter: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        var path = Path()

        func noise(_ i: Int) -> CGFloat {
            // Simple smooth pseudo-noise by combining sines
            let f1 = sin(phase + CGFloat(i) * 0.9)
            let f2 = sin(phase * 0.7 + CGFloat(i) * 1.7)
            let f3 = sin(phase * 1.3 + CGFloat(i) * 2.3)
            let n = (f1 + f2 * 0.6 + f3 * 0.4) / 2.0
            return 1.0 + n * jitter
        }

        let count = max(3, points)
        let step = 2 * CGFloat.pi / CGFloat(count)
        var pts: [CGPoint] = []

        for i in 0..<count {
            let angle = CGFloat(i) * step
            let r = baseRadius * noise(i)
            let p = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            pts.append(p)
        }

        guard let first = pts.first else { return path }
        path.move(to: first)

        // Use smooth cubic curves between points
        for i in 0..<count {
            let current = pts[i]
            let next = pts[(i + 1) % count]
            let prev = pts[(i - 1 + count) % count]

            let c1 = controlPoint(from: prev, to: current, center: center, smoothness: 0.25)
            let c2 = controlPoint(from: next, to: current, center: center, smoothness: 0.25)

            path.addCurve(to: next, control1: c1, control2: c2)
        }

        path.closeSubpath()
        return path
    }

    private func controlPoint(from a: CGPoint, to b: CGPoint, center: CGPoint, smoothness: CGFloat) -> CGPoint {
        let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
        let dx = mid.x - center.x
        let dy = mid.y - center.y
        return CGPoint(x: mid.x + dx * smoothness, y: mid.y + dy * smoothness)
    }
}

#Preview {
    VStack(spacing: 24) {
        AnimatedBlobView(color: .pink, size: 220, speed: 0.8, points: 9, jitter: 0.28)
        AnimatedBlobView(color: .purple, size: 160, speed: 0.5, points: 7, jitter: 0.22)
    }
    .padding()
}
