// Created by Cursor on 3/3/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ResearchBarView: View {
    let totalSeconds: TimeInterval
    let completedSeconds: TimeInterval

    private var clampedProgress: Double {
        guard totalSeconds > 0 else { return 0 }
        let raw = completedSeconds / totalSeconds
        return min(max(raw, 0), 1)
    }

    private var remainingSeconds: TimeInterval {
        max(totalSeconds - completedSeconds, 0)
    }
}

// MARK: - Rendering

extension ResearchBarView {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                bar(geometry: geometry)
                Text(CompactDurationFormat.string(fromInterval: remainingSeconds, roundingRule: .up))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.primary)
            }
        }
        .frame(height: 20)
    }

    private func bar(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(AccentColors.slate)

            overlay(geometry: geometry)

        }
        .frame(height: 20)
    }

    private func overlay(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(AccentColors.amethyst)
                .frame(width: geometry.size.width * clampedProgress)
            Spacer(minLength: 0)
        }
        .clipShape(Capsule())
    }

}

// MARK: - Previews

#Preview {
    VStack(spacing: 16) {
        ResearchBarView(totalSeconds: 45, completedSeconds: 10)
        ResearchBarView(totalSeconds: 5 * 60, completedSeconds: 75)
        ResearchBarView(totalSeconds: 90 * 60, completedSeconds: 30 * 60)
        ResearchBarView(totalSeconds: 3 * 86_400, completedSeconds: 86_400 + 3600 + 30)
    }
    .padding()
}
