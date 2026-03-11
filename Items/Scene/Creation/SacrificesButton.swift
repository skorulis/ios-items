//Created by Alexander Skorulis on 11/3/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

/// Compact pentagram button matching `PortalCornerButton` size (44×44).
/// Stroke reflects how much of `config` is satisfied by `plan`: green (full), yellow (partial), grey (none / empty).
struct SacrificesButton {

    /// Matches `PortalCornerButton` frame.
    static let size: CGFloat = 44

    private let model: Model
    
    init(model: Model) {
        self.model = model
    }
}

// MARK: - Inner Types

extension SacrificesButton {
    struct Model {
        let config: SacrificeConfig
        let plan: SacrificePlan
        let action: () -> Void
    }
}

// MARK: - Rendering

extension SacrificesButton: View {
    
    var body: some View {
        Button(action: model.action) {
            ZStack {
                PentagramCircumcircleShape(layoutInset: 0)
                    .stroke(strokeColor, lineWidth: 2)
                PentagramShape(layoutInset: 0)
                    .stroke(strokeColor, lineWidth: 2)
            }
            .frame(width: Self.size, height: Self.size)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var strokeColor: Color {
        var configuredSlots: [(Int, BaseItem)] = []
        for index in 0..<SacrificeConfig.slotCount {
            if let item = model.config.item(at: index) {
                configuredSlots.append((index, item))
            }
        }
        if configuredSlots.isEmpty {
            return .gray
        }
        var satisfiedCount = 0
        for (index, configuredItem) in configuredSlots {
            if model.plan.item(at: index) == configuredItem {
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
            model: .init(
                config: SacrificeConfig(slots: [:]),
                plan: SacrificePlan(slotsByIndex: [:]),
                action: {},
            )
        )
        SacrificesButton(
            model: .init(
                config: SacrificeConfig(slots: [0: .apple, 1: .rock]),
                plan: SacrificePlan(slotsByIndex: [0: .apple, 1: nil]),
                action: {},
            )
        )
        SacrificesButton(
            model: .init(
                config: SacrificeConfig(slots: [0: .apple]),
                plan: SacrificePlan(slotsByIndex: [0: .apple]),
                action: {},
            )
        )
    }
    .padding()
}
