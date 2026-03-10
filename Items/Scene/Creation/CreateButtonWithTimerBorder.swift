//Created by Alexander Skorulis on 11/3/2026.

import SwiftUI

// MARK: - Memory footprint

/// Wraps the create button with an optional animated progress border that shows auto-creation timer progress.
@MainActor struct CreateButtonWithTimerBorder<Label: View> {
    @ViewBuilder let label: () -> Label
    let action: () async -> Void
    let timer: TimerProgressView.Model?

    @State private var progress: Double = 0

    init(
        timer: TimerProgressView.Model?,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.timer = timer
        self.action = action
        self.label = label
    }
}

// MARK: - Rendering

extension CreateButtonWithTimerBorder: View {
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            label()
        }
        .buttonStyle(CapsuleButtonStyle())
        .overlay {
            if timer != nil {
                CapsuleProgressStroke(progress: progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: timer?.id) { _, _ in
            runAnimation()
        }
        .onAppear {
            runAnimation()
        }
    }

    private func runAnimation() {
        progress = 0
        guard let timer, timer.duration > 0.01 else { return }
        DispatchQueue.main.async {
            withAnimation(.linear(duration: timer.duration)) {
                progress = 1
            }
        }
    }
}

// MARK: - Capsule progress stroke shape

private struct CapsuleProgressStroke: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        return Capsule().path(in: rect).trimmedPath(from: 0, to: progress)
    }
}
