//Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Models
import SwiftUI

/// Compact pentagram button matching `PortalCornerButton` size (44×44).
/// Stroke reflects how much of `config` is satisfied by `plan`: green (full), yellow (partial), grey (none / empty).
struct SacrificesButton: View {

    /// Matches `PortalCornerButton` frame.
    static let size: CGFloat = 44

    /// Inset so the star fits inside the circle without clipping (1px stroke).
    private static let pentagramInset: CGFloat = 0

    let config: SacrificeConfig
    let plan: SacrificePlan
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                PentagramCircumcircleShape(layoutInset: Self.pentagramInset)
                    .stroke(strokeColor, lineWidth: 2)
                PentagramShape(layoutInset: Self.pentagramInset)
                    .stroke(strokeColor, lineWidth: 2)
            }
            .frame(width: Self.size, height: Self.size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var strokeColor: Color {
        Self.strokeColor(config: config, plan: plan)
    }

    /// Green = every configured slot satisfied by plan; yellow = some but not all; grey = none configured or none satisfiable.
    static func strokeColor(config: SacrificeConfig, plan: SacrificePlan) -> Color {
        var configuredSlots: [(Int, BaseItem)] = []
        for index in 0..<SacrificeConfig.slotCount {
            if let item = config.item(at: index) {
                configuredSlots.append((index, item))
            }
        }
        if configuredSlots.isEmpty {
            return .gray
        }
        var satisfiedCount = 0
        for (index, configuredItem) in configuredSlots {
            if plan.item(at: index) == configuredItem {
                satisfiedCount += 1
            }
        }
        if satisfiedCount == configuredSlots.count {
            return .green
        }
        if satisfiedCount == 0 {
            return .gray
        }
        return .yellow
    }
}

// MARK: - Preview

#Preview("SacrificesButton states") {
    HStack(spacing: 16) {
        SacrificesButton(
            config: SacrificeConfig(slots: [:]),
            plan: SacrificePlan(slotsByIndex: [:]),
            action: {}
        )
        SacrificesButton(
            config: SacrificeConfig(slots: [0: .apple, 1: .rock]),
            plan: SacrificePlan(slotsByIndex: [0: .apple, 1: nil]),
            action: {}
        )
        SacrificesButton(
            config: SacrificeConfig(slots: [0: .apple]),
            plan: SacrificePlan(slotsByIndex: [0: .apple]),
            action: {}
        )
    }
    .padding()
}
