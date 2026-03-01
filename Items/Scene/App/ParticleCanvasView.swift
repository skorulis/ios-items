import SwiftUI

// MARK: - Single particle (pre-rendered symbol for Canvas)

/// A single particle drawn as a blurry circle with additive blending.
/// Used as a Canvas symbol for performant repeated drawing.
private struct SingleParticleView: View {
    var body: some View {
        Circle()
            .fill(Color.orange.opacity(0.4))
            .frame(width: 35, height: 35)
            .blendMode(.plusLighter)
            .blur(radius: 10)
    }
}

// MARK: - Particle canvas (fire-like animation)

/// Fire-like particle effect using SwiftUI Canvas.
/// Particles move upward with a cosine wave, fading out as they rise.
/// Based on: https://nerdyak.tech/development/2024/06/27/particle-effects-with-SwiftUI-Canvas.html
struct ParticleCanvasView: View {
    let movementDuration: Double
    let particleCount: Int
    let startingParticleOffsets: [CGFloat]
    let startingParticleAlphas: [CGFloat]

    init(particleCount: Int = 200, movementDuration: Double = 3.0) {
        self.particleCount = particleCount
        self.movementDuration = movementDuration
        self.startingParticleOffsets = (0 ..< particleCount).map { _ in CGFloat.random(in: 0 ... 1) }
        self.startingParticleAlphas = (0 ..< particleCount).map { _ in CGFloat.random(in: 0 ... .pi * 2) }
    }

    func particlePositionAndAlpha(index: Int, timeInterval: Double, canvasSize: CGSize) -> (CGPoint, CGFloat) {
        let startingRotation: CGFloat = startingParticleAlphas[index]
        let startingTimeOffset = startingParticleOffsets[index] * movementDuration

        let time = (timeInterval + startingTimeOffset).truncatingRemainder(dividingBy: movementDuration) / movementDuration
        let rotations: CGFloat = 1.5
        let amplitude: CGFloat = 0.1 + 0.8 * (1 - time)

        let x = canvasSize.width / 2 + cos(rotations * time * .pi * 2 + startingRotation) * canvasSize.width / 2 * amplitude * 0.8
        let y = (1 - time * time) * canvasSize.height

        return (CGPoint(x: x, y: y), 1 - time)
    }

    var body: some View {
        TimelineView(.animation) { context in
            let timeInterval = context.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                guard let particleSymbol = context.resolveSymbol(id: 0) else { return }

                for i in 0 ..< particleCount {
                    let positionAndAlpha = particlePositionAndAlpha(index: i, timeInterval: timeInterval, canvasSize: size)
                    context.opacity = positionAndAlpha.1
                    context.draw(particleSymbol, at: positionAndAlpha.0, anchor: .center)
                }
            } symbols: {
                SingleParticleView()
                    .tag(0)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ParticleCanvasView(particleCount: 200, movementDuration: 3.0)
        .frame(width: 300, height: 300)
        .background(Color.black.opacity(0.8))
        .padding()
}
