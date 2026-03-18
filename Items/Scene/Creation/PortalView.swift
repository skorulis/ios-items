// Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import Knit
import SwiftUI

// MARK: - Portal view

/// Encapsulates the dimensional portal background and corner action buttons.
struct PortalView: View {

    let upgradesButton: ButtonOrProgress?
    let researchButton: Button?
    let mapLocationsButton: Button?
    let sacrificesButton: SacrificesButton.Model?

    @Binding var sacrificesFrame: CGRect

    /// Frames for each visible corner control; overlay draws a wire from each center to the portal.
    private var wireSourceFrames: [CGRect] {
        var frames: [CGRect] = []
        if let upgradesButton {
            switch upgradesButton {
            case let .button(button):
                frames.append(button.frameBinding.wrappedValue)
            case .progress:
                break
            }
        }
        if sacrificesButton != nil {
            frames.append(sacrificesFrame)
        }
        if let mapLocationsButton {
            frames.append(mapLocationsButton.frameBinding.wrappedValue)
        }
        if let researchButton {
            frames.append(researchButton.frameBinding.wrappedValue)
        }
        return frames
    }

    private var hasActiveWireFrames: Bool {
        wireSourceFrames.contains { $0.width > 0 && $0.height > 0 }
    }

    var body: some View {
        ZStack {
            if hasActiveWireFrames {
                PortalCircuitWiresOverlay(sourceFrames: wireSourceFrames)
            }
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
                buttonOrProgress(upgradesButton)
            }
            Spacer(minLength: 0)
            if let sacrificesButton {
                SacrificesButton(model: sacrificesButton)
                    .readFrame(frame: $sacrificesFrame)
            }
        }
    }

    @ViewBuilder
    private func buttonOrProgress(_ model: ButtonOrProgress) -> some View {
        switch model {
        case let .button(button):
            PortalCornerButton(
                icon: Image(systemName: "arrow.up.circle.fill"),
                action: button.action,
                badge: button.badge,
                frameBinding: button.frameBinding,
            )
        case let .progress(amount, action):
            SwiftUI.Button(action: action) {
                PortalUpgradesProgressRing(amount: amount)
            }
            .buttonStyle(.plain)
        }
    }

    private var bottomButtons: some View {
        HStack {
            if let mapLocationsButton {
                PortalCornerButton(
                    icon: Image(systemName: "map.fill"),
                    action: mapLocationsButton.action,
                    badge: mapLocationsButton.badge,
                    frameBinding: mapLocationsButton.frameBinding
                )
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
        let badge: BadgeContent?
        let frameBinding: Binding<CGRect>
    }

    enum BadgeContent {
        case count(Int)
        case icon(Image)
    }

    enum ButtonOrProgress {
        case button(Button)
        case progress(CGFloat, action: () -> Void)
    }
}

// MARK: - Portal corner button

/// A circular button with an icon and an optional badge in the top-right corner.
struct PortalCornerButton: View {
    let icon: Image
    let action: () -> Void
    var badge: PortalView.BadgeContent?
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
                if let badge {
                    badgeContent(badge: badge)
                        .background(Circle().fill(Color.red))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .readFrame(frame: frameBinding)
    }

    @ViewBuilder
    private func badgeContent(badge: PortalView.BadgeContent) -> some View {
        switch badge {
        case let .count(value) where value > 0:
            Text("\(value)")
                .font(.appMonospaceBadge)
                .foregroundStyle(.white)
                .frame(minWidth: 18, minHeight: 18)
        case let .icon(image):
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(4)
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
        default:
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("Portal view upgrades progress ring") {
    PortalView(
        upgradesButton: .progress(0.65, action: {}),
        researchButton: nil,
        mapLocationsButton: nil,
        sacrificesButton: nil,
        sacrificesFrame: .constant(.zero),
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
}

#Preview("Portal view with upgrades") {
    PortalView(
        upgradesButton: .button(.init(action: {}, badge: nil, frameBinding: .constant(.zero))),
        researchButton: nil,
        mapLocationsButton: .init(action: {}, badge: nil, frameBinding: .constant(.zero)),
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
