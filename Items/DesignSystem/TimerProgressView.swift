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
        ProgressView(value: progress, total: 1)
            .progressViewStyle(.linear)
            .tint(.accentColor)
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
            withAnimation(.linear(duration: 14)) {
                progress = 1
            }
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var timerId = UUID()

    return VStack(spacing: 16) {
        TimerProgressView(timerId: timerId, duration: 13)
        Button("Restart animation") {
            timerId = UUID()
        }
    }
    .padding()
}
