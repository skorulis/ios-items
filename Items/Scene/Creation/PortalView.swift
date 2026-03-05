//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Portal view

/// Encapsulates the dimensional portal background and corner action buttons.
struct PortalView: View {

    var upgradesButton: Button?

    var body: some View {
        ZStack {
            dimensionalPortalBackground
            cornerButtons
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var dimensionalPortalBackground: some View {
        Asset.Creation.dimensionalPortal.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 280, maxHeight: 280)
    }

    @ViewBuilder
    private var cornerButtons: some View {
        if let upgradesButton {
            VStack {
                HStack {
                    PortalCornerButton(
                        icon: Image(systemName: "arrow.up.circle.fill"),
                        action: upgradesButton.action,
                        badge: upgradesButton.badge
                    )
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
}

extension PortalView {
    struct Button {
        let action: () -> Void
        let badge: Int
    }
}

// MARK: - Portal corner button

/// A circular button with an icon and an optional badge in the top-right corner.
struct PortalCornerButton: View {
    let icon: Image
    let action: () -> Void
    var badge: Int? = nil

    private let size: CGFloat = 44

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: size, height: size)
                    .overlay {
                        icon
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                if let badge, badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(Circle().fill(Color.red))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Portal view with upgrades") {
    PortalView(
        upgradesButton: .init(action: {}, badge: 0),
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.3))
}
