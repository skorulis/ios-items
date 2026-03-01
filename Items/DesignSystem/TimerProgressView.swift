//Created by Alexander Skorulis on 2/3/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

/// Animates progress from 0 to 1 over a given duration. Resets and restarts the animation whenever `timerId` changes,
@MainActor struct TimerProgressView: View {
    let timerId: UUID
    let duration: TimeInterval

    @State private var progress: Double = 0
    
    init(
        timerId: UUID,
        duration: TimeInterval
    ) {
        self.timerId = timerId
        self.duration = duration
    }
    
    init(model: Model) {
        self.init(timerId: model.id, duration: model.duration)
    }
}

extension TimerProgressView {
    struct Model: Equatable, Sendable {
        let id: UUID
        let duration: TimeInterval
    }
}

// MARK: - Rendering

extension TimerProgressView {
    var body: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            CircleWedge(progress: progress)
                .fill(.tint)
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: timerId) { _, _ in
            runAnimation()
        }
        .onAppear {
            runAnimation()
        }
    }

    private func runAnimation() {
        progress = 0
        guard duration > 0.01 else { return }
        DispatchQueue.main.async {
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
}

// MARK: - Circle wedge shape

private struct CircleWedge: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = Angle.degrees(-90)
        let endAngle = Angle.degrees(-90 + 360 * progress)
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var timerId = UUID()

    return VStack(spacing: 16) {
        TimerProgressView(timerId: timerId, duration: 3)
            .frame(width: 64, height: 64)
        Button("Restart animation") {
            timerId = UUID()
        }
    }
    .padding()
}
