import SwiftUI

// MARK: - Single particle (pre-rendered symbol for Canvas)

/// A single particle drawn as a blurry circle with additive blending.
/// Used as a Canvas symbol for performant repeated drawing.
private struct SingleParticleView: View {
    var color: Color = .orange

    var body: some View {
        Circle()
            .fill(color.opacity(0.4))
            .frame(width: 24, height: 24)
            .blendMode(.plusLighter)
            .blur(radius: 10)
    }
}

// MARK: - Particle canvas (spiral to center)

/// Particle effect using SwiftUI Canvas.
/// Particles spawn at random points on a ring and spiral inward toward the center over a fixed duration.
/// At the end of the duration all particles are at the center.
/// Based on: https://nerdyak.tech/development/2024/06/27/particle-effects-with-SwiftUI-Canvas.html
struct ParticleCanvasView: View {
    let movementDuration: Double
    let particleCount: Int
    /// Number of full rotations each particle makes as it travels from ring to center.
    let spiralTurns: CGFloat
    /// When non-nil and non-empty, each particle is assigned a random color from this array.
    let colors: [Color]
    /// Stable across parent re-renders so we don't regenerate and cause CPU spikes when view model updates.
    @State private var startingParticleOffsets: [CGFloat]
    @State private var startingParticleAlphas: [CGFloat]
    @State private var particleColorIndices: [Int]
    /// When the animation started; used to compute elapsed time for the one-shot animation.
    @State private var startTime: Date = Date()

    init(
        particleCount: Int = 100,
        movementDuration: Double = 1.5,
        spiralTurns: CGFloat = 0.5,
        colors: [Color] = [.gray, .blue],
    ) {
        self.particleCount = particleCount
        self.movementDuration = movementDuration
        self.spiralTurns = spiralTurns
        self.colors = colors
        _startingParticleOffsets = State(initialValue: (0 ..< particleCount).map { _ in CGFloat.random(in: 0 ... 1) })
        _startingParticleAlphas = State(initialValue: (0 ..< particleCount).map { _ in CGFloat.random(in: 0 ... .pi * 2) })
        _particleColorIndices = State(initialValue: (0 ..< particleCount).map { _ in
            Int.random(in: 0 ..< colors.count)
        })
    }

    /// Normalized time 0...1 over the fixed duration. 1 = all particles at center.
    private func normalizedTime(from timeInterval: Double) -> CGFloat {
        let elapsed = timeInterval - startTime.timeIntervalSinceReferenceDate
        guard movementDuration > 0 else { return 1 }
        return CGFloat(min(1, max(0, elapsed / movementDuration)))
    }

    func particlePositionAndAlpha(index: Int, timeInterval: Double, canvasSize: CGSize) -> (CGPoint, CGFloat) {
        let cx = canvasSize.width / 2
        let cy = canvasSize.height / 2
        let ringRadius = min(canvasSize.width, canvasSize.height) / 2
        let startAngle: CGFloat = startingParticleAlphas[index]
        let startOffset: CGFloat = startingParticleOffsets[index]
        let t = normalizedTime(from: timeInterval)

        if t <= startOffset {
            let radiusAtTime = ringRadius
            let angle = startAngle
            let x = cx + cos(angle) * radiusAtTime
            let y = cy + sin(angle) * radiusAtTime
            return (CGPoint(x: x, y: y), 0)
        }
        let remaining = max(0.01, 1 - startOffset)
        let localT = min(1, (t - startOffset) / remaining)
        let radiusAtTime = (1 - localT) * ringRadius
        let angle = startAngle + spiralTurns * localT * .pi * 2
        let x = cx + cos(angle) * radiusAtTime
        let y = cy + sin(angle) * radiusAtTime
        return (CGPoint(x: x, y: y), localT)
    }

    var body: some View {
        let colorList = colors
        return TimelineView(.animation) { context in
            let timeInterval = context.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                for i in 0 ..< particleCount {
                    let symbolId = particleColorIndices[i] % colorList.count
                    guard let particleSymbol = context.resolveSymbol(id: symbolId) else { continue }
                    let positionAndAlpha = particlePositionAndAlpha(index: i, timeInterval: timeInterval, canvasSize: size)
                    context.opacity = positionAndAlpha.1
                    context.draw(particleSymbol, at: positionAndAlpha.0, anchor: .center)
                }
            } symbols: {
                ForEach(Array(colorList.enumerated()), id: \.offset) { index, color in
                    SingleParticleView(color: color)
                        .tag(index)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var animationID = UUID()
    
    ZStack(alignment: .bottom) {
        ParticleCanvasView()
            .id(animationID)
            .border(Color.red)
        
        Button("Restart") {
            animationID = UUID()
        }
    }
    
}
