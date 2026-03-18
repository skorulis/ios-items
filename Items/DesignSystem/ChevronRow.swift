// Created by Alexander Skorulis on 20/2/2026.

import SwiftUI

/// Tappable row with optional leading content and a fixed trailing chevron.
public struct ChevronRow<Leading: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let subtitle: String?
    private let leading: Leading
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                leading
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(isEnabled ? .primary : .secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(isEnabled ? .secondary : .tertiary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isEnabled ? .primary : .secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .opacity(isEnabled ? 1 : 0.5)
        .disabled(!isEnabled)
        .buttonStyle(PressableRowStyle())
    }

    private struct PressableRowStyle: ButtonStyle {
        var pressedBackground: Color = Color.secondary.opacity(0.12)
        var normalBackground: Color = .clear
        
        @Environment(\.margin) private var margin

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(
                    Rectangle()
                        .fill(configuration.isPressed ? pressedBackground : normalBackground)
                        .padding(.horizontal, -(margin ?? 0))
                )
        }
    }
}

// MARK: - No leading

public extension ChevronRow where Leading == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            leading: { EmptyView() },
            action: action
        )
    }
}

// MARK: - Preview

struct ChevronRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ChevronRow(title: "Settings") {}
            ChevronRow(title: "Profile", subtitle: "View and edit") {}

            ChevronRow(
                title: "With icon",
                leading: {
                    Image(systemName: "wifi")
                        .foregroundStyle(.blue)
                        .frame(width: 28, height: 28)
                },
                action: {}
            )
        }
        .margin()
    }
}
