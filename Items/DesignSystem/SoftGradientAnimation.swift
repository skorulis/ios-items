import SwiftUI

struct SoftGradientAnimation: View {
    let colors: [Color]

    private let meshWidth = 4
    private let meshHeight = 4
    private var gridCount: Int { meshWidth * meshHeight }

    /// Builds 16 colors by repeating the input palette and mixing in white at some positions.
    private var meshColors: [Color] {
        guard !colors.isEmpty else { return Array(repeating: .white, count: gridCount) }
        let colorsWithWhite = colors + [.white]
        return (0 ..< gridCount).map { index in
            let base = colorsWithWhite[index % colorsWithWhite.count]
            // Mix with white at alternating positions for a softer, more varied look
            let mixWhite: Double = (index % 3 == 0) ? 0.25 : ((index % 3 == 1) ? 0.15 : 0.0)
            return base.mix(with: .white, by: mixWhite)
        }
    }

    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince1970
            let offsetX = Float(sin(time)) * 0.08
            let offsetY = Float(cos(time * 0.9)) * 0.08

            MeshGradient(
                width: meshWidth,
                height: meshHeight,
                points: Self.points(offsetX: offsetX, offsetY: offsetY),
                colors: meshColors
            )
        }
        .drawingGroup() // can help with animation performance
    }

    /// 4×4 grid points; interior points (row 1–2, col 1–2) are offset for animation.
    private static func points(offsetX: Float, offsetY: Float) -> [SIMD2<Float>] {
        [
            [0.0, 0.0], [0.3, 0.0], [0.7, 0.0], [1.0, 0.0],
            [0.0, 0.3], [0.2 + offsetX, 0.4 + offsetY], [0.7 + offsetX, 0.2 + offsetY], [1.0, 0.3],
            [0.0, 0.7], [0.3 + offsetX, 0.8 + offsetY], [0.7 + offsetX, 0.6 + offsetY], [1.0, 0.7],
            [0.0, 1.0], [0.3, 1.0], [0.7, 1.0], [1.0, 1.0],
        ]
    }

}

#Preview("Soft gradient") {
    SoftGradientAnimation(colors: [.purple, .mint, .orange, .blue])
        .ignoresSafeArea()
}

#Preview("Two colors") {
    SoftGradientAnimation(colors: [.indigo, .pink])
        .ignoresSafeArea()
}
