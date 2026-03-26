// Created by Alexander Skorulis on 24/3/2026.

import Foundation

/// Shared formatting for short, human-readable durations (research timers, mission time, etc.).
enum CompactDurationFormat {

    /// Formats a non-negative duration after rounding the interval to whole seconds.
    static func string(
        fromInterval interval: TimeInterval,
        roundingRule: FloatingPointRoundingRule
    ) -> String {
        let clamped = max(0, interval)
        let totalSeconds = Int(clamped.rounded(roundingRule))
        return string(fromTotalSeconds: totalSeconds)
    }

    /// Formats a non-negative duration from a whole-second count.
    static func string(fromTotalSeconds totalSeconds: Int) -> String {
        let safe = max(0, totalSeconds)
        if safe < 60 {
            return "\(safe)s"
        }
        if safe < 3600 {
            let mins = safe / 60
            let seconds = safe % 60
            return String(format: "%dm %02ds", mins, seconds)
        }
        if safe < 86_400 {
            let hours = safe / 3600
            let mins = (safe % 3600) / 60
            let seconds = safe % 60
            return String(format: "%dh %02dm %02ds", hours, mins, seconds)
        }
        let days = safe / 86_400
        let rem = safe % 86_400
        let hours = rem / 3600
        let mins = (rem % 3600) / 60
        let seconds = rem % 60
        return String(format: "%dd %02dh %02dm %02ds", days, hours, mins, seconds)
    }
}
