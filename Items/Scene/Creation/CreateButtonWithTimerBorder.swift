// Created by Alexander Skorulis on 11/3/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct AutoCreationButtonWithTimerBorder<Label: View> {
    @ViewBuilder let label: () -> Label
    let action: () -> Void
    let timer: TimerProgressView.Model?

    init(
        timer: TimerProgressView.Model?,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.timer = timer
        self.action = action
        self.label = label
    }
}

// MARK: - Rendering

extension AutoCreationButtonWithTimerBorder: View {
    var body: some View {
        Button(action: action) {
            label()
        }
        .buttonStyle(.plain)
        .timerProgressBorder(timer: timer)
    }
}

private struct TimerProgressBorderModifier: ViewModifier {
    let timer: TimerProgressView.Model?

    @State private var progress: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if timer != nil {
                    CircleProgressStroke(progress: progress)
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(.degrees(-90))
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

private extension View {
    func timerProgressBorder(timer: TimerProgressView.Model?) -> some View {
        modifier(TimerProgressBorderModifier(timer: timer))
    }
}

// MARK: - Progress stroke shapes

private struct CircleProgressStroke: Shape {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress > 0 else { return Path() }
        return Circle().path(in: rect).trimmedPath(from: 0, to: progress)
    }
}
