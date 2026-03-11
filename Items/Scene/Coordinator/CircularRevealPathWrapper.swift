// Created for circular reveal overlay for Portal Upgrades.

import ASKCoordinator
import SwiftUI

// MARK: - Overlay name

extension CustomOverlay.Name {
    /// Full-screen overlay with circular expand/shrink from a source rect.
    static let circularReveal = CustomOverlay.Name("circularReveal")
}

// MARK: - Dismiss callback for overlay content

extension EnvironmentValues {
    @Entry var dismissCircularReveal: (() -> Void)?
}

// MARK: - Circular mask modifier

private struct CircularRevealMaskModifier: ViewModifier, Animatable {
    var progress: CGFloat
    let center: CGPoint

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    /// Line width of the boundary ring at the mask edge.
    private static let ringLineWidth: CGFloat = 2

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            let maxRadius = hypot(size.width, size.height)
            let radius = maxRadius * progress

            ZStack {
                content
                    .mask(
                        Circle()
                            .frame(width: radius * 2, height: radius * 2)
                            .position(x: center.x, y: center.y)
                    )

                // Ring on the mask edge: separates revealed (inside) from hidden (outside).
                if radius > 0 {
                    Circle()
                        .stroke(
                            Color.primary.opacity(0.4),
                            lineWidth: Self.ringLineWidth
                        )
                        .frame(width: radius * 2, height: radius * 2)
                        .position(x: center.x, y: center.y)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Wrapper view

struct CircularRevealPathWrapper<Content: View>: View {
    let path: any CoordinatorPath
    let content: () -> Content

    @Environment(\.dismissCustomOverlay) private var onDismiss
    @State private var revealProgress: CGFloat = 0
    @State private var isDismissing = false
    
    var circularPathRect: CGRect {
        return (path as? CircularAnimationPath)?.sourceRect ?? .zero
    }

    var body: some View {
        GeometryReader { proxy in
            let overlayFrame = proxy.frame(in: .global)
            let rect = circularPathRect
            let center = CGPoint(
                x: rect.midX - overlayFrame.minX,
                y: rect.midY - overlayFrame.minY
            )

            content()
                .background(ignoresSafeAreaEdges: .all)
                .modifier(CircularRevealMaskModifier(progress: revealProgress, center: center))
                .environment(\.dismissCircularReveal, requestDismiss)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.45)) {
                revealProgress = 1
            }
        }
    }

    private func requestDismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        withAnimation(.easeInOut(duration: 0.45)) {
            revealProgress = 0
        } completion: {
            onDismiss()
        }
    }
}
