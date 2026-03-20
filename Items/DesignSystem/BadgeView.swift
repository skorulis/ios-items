// Created by Alexander Skorulis on 20/3/2026.

import SwiftUI

/// Small notification marker: a red dot or a pill with a numeric count.
public struct BadgeView: View {

    public enum Style: Equatable {
        case dot
        case number(Int)
    }

    private let style: Style?

    /// Pass `nil` to hide the badge.
    public init(style: Style?) {
        self.style = style
    }

    public var body: some View {
        switch style {
        case nil:
            EmptyView()
        case .dot:
            Circle()
                .fill(Color.red)
                .frame(width: Self.dotSize, height: Self.dotSize)
                .accessibilityLabel("New")
        case .number(let raw):
            Group {
                if raw > 0 {
                    numberPill(raw: raw, text: Self.numberText(raw))
                }
            }
        }
    }

    @ViewBuilder
    private func numberPill(raw: Int, text: String) -> some View {
        Text(text)
            .font(.appCaption.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.white)
            .padding(.horizontal, text.count > 1 ? 6 : 5)
            .frame(minWidth: Self.numberMinHeight - 2, minHeight: Self.numberMinHeight)
            .background(Capsule().fill(Color.red))
            .accessibilityLabel("\(raw) new")
    }

    private static let dotSize: CGFloat = 10
    private static let numberMinHeight: CGFloat = 20

    private static func numberText(_ value: Int) -> String {
        if value <= 0 { return "0" }
        if value > 99 { return "99+" }
        return "\(value)"
    }
}

// MARK: - Previews

#Preview("BadgeView") {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Dot")
            BadgeView(style: .dot)
        }
        HStack {
            Text("Single digit")
            BadgeView(style: .number(3))
        }
        HStack {
            Text("Many")
            BadgeView(style: .number(140))
        }
        HStack {
            Text("Hidden")
            BadgeView(style: nil)
        }
    }
    .padding()
}
