//Created by Cursor on 3/3/2026.

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
                Text(formattedRemainingTime(remainingSeconds))
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
    
    private func formattedRemainingTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = max(Int(ceil(timeInterval)), 0)
        
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        }
        
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = (totalSeconds / 3600) % 24
        let days = totalSeconds / 86400
        
        if totalSeconds < 3600 {
            // Under 1 hour: MM:SS
            return String(format: "%dm %02ds", minutes, seconds)
        } else if totalSeconds < 86_400 {
            // Under 1 day: H:MM:SS
            let totalHours = totalSeconds / 3600
            return String(format: "%dh %02dm %02ds", totalHours, minutes, seconds)
        } else {
            // 1 day or more: Dd HH:MM:SS
            return String(format: "%dd %02dh %02dm %02ds", days, hours, minutes, seconds)
        }
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

