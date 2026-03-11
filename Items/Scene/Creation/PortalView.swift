//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import Knit
import SwiftUI

// MARK: - Portal view

/// Encapsulates the dimensional portal background and corner action buttons.
struct PortalView: View {

    let upgradesButton: ButtonOrProgress?
    let researchButton: Button?
    let artifactButton: ArtifactSlotView?
    let sacrificesButton: SacrificesButton.Model?
    @Binding var sacrificesFrame: CGRect

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
    
    private var topButtons: some View {
        HStack {
            if let upgradesButton {
                switch upgradesButton {
                case let .button(button):
                    PortalCornerButton(
                        icon: Image(systemName: "arrow.up.circle.fill"),
                        action: button.action,
                        badge: button.badge,
                        frameBinding: button.frameBinding,
                    )
                case let .progress(amount):
                    PortalUpgradesProgressRing(amount: amount)
                }
            }
            Spacer(minLength: 0)
            if let sacrificesButton {
                SacrificesButton(model: sacrificesButton)
                    .readFrame(frame: $sacrificesFrame)
            }
        }
    }
    
    private var bottomButtons: some View {
        HStack {
            if let artifactButton {
                artifactButton
            }
            Spacer(minLength: 0)
            if let researchButton {
                PortalCornerButton(
                    icon: Image(systemName: "flask.fill"),
                    action: researchButton.action,
                    badge: researchButton.badge,
                    frameBinding: researchButton.frameBinding,
                )
            }
        }
    }

    @ViewBuilder
    private var cornerButtons: some View {
        VStack {
            topButtons
            Spacer(minLength: 0)
            bottomButtons
        }
        .padding()
    }
}

extension PortalView {
    struct Button {
        let action: () -> Void
        let badge: Int
        let frameBinding: Binding<CGRect>
    }
    
    enum ButtonOrProgress {
        case button(Button)
        case progress(CGFloat)
    }
}

// MARK: - Portal corner button

/// A circular button with an icon and an optional badge in the top-right corner.
struct PortalCornerButton: View {
    let icon: Image
    let action: () -> Void
    var badge: Int? = nil
    let frameBinding: Binding<CGRect>

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
        .readFrame(frame: frameBinding)
    }
}

// MARK: - Previews

#Preview("Portal view upgrades progress ring") {
    PortalView(
        upgradesButton: .progress(0.65),
        researchButton: nil,
        artifactButton: nil,
        sacrificesButton: nil,
        sacrificesFrame: .constant(.zero),
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
}

#Preview("Portal view with upgrades") {
    PortalView(
        upgradesButton: .button(.init(action: {}, badge: 0, frameBinding: .constant(.zero))),
        researchButton: nil,
        artifactButton: ArtifactSlotView(
            slots: [.init(type: .eternalHourglass, quality: .junk), nil],
            size: .small,
        ),
        sacrificesButton: SacrificesButton.Model(
            config: .init(slots: [:]),
            plan: .init(itemsInOrder: [.apple]),
            action: {},
        ),
        sacrificesFrame: .constant(.zero),
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
}
