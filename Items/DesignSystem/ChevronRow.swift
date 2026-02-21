//Created by Alexander Skorulis on 20/2/2026.

import SwiftUI

public struct ChevronRow<Accessory: View>: View {
    private let title: String
    private let subtitle: String?
    private let accessory: Accessory
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder accessory: () -> Accessory = { EmptyView() },
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Spacer(minLength: 8)
                accessory
                Image(systemName: "chevron.forward")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Convenience initializers without accessory
public extension ChevronRow where Accessory == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            accessory: { EmptyView() },
            action: action
        )
    }
}

// MARK: - Preview
struct ChevronRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                ChevronRow(title: "Settings") {}
                ChevronRow(title: "Profile", subtitle: "View and edit") {}
            }
            .listStyle(.insetGrouped)
            .previewDisplayName("ChevronRow - Title only")

            List {
                ChevronRow(title: "Wi‑Fi", subtitle: "Home Network") {
                    Image(systemName: "wifi")
                        .foregroundStyle(.blue)
                } action: {}

                ChevronRow(title: "Notifications") {
                    Toggle(isOn: .constant(true)) { EmptyView() }
                        .labelsHidden()
                } action: {}
            }
            .listStyle(.insetGrouped)
            .previewDisplayName("ChevronRow - With accessory")
        }
    }
}
