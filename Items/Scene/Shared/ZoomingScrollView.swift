// Created by Cursor on 25/3/2026.

import SwiftUI
import UIKit

/// Pinch to zoom and pan using `UIScrollView`, hosting SwiftUI content at a fixed logical size.
/// Double-tap resets zoom and re-centers on `initialCenterPoint`.
struct ZoomingScrollView<Content: View>: UIViewRepresentable {

    var contentSize: CGSize
    var minimumZoomScale: CGFloat = 0.5
    var maximumZoomScale: CGFloat = 1.1
    /// Point in the content view’s coordinate space to place in the viewport center on first layout and after double-tap reset.
    var initialCenterPoint: CGPoint
    @ViewBuilder var content: () -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = ZoomScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never

        let container = UIView(frame: CGRect(origin: .zero, size: contentSize))
        container.backgroundColor = .clear

        let hosting = UIHostingController(rootView: content())
        hosting.view.backgroundColor = .clear
        hosting.view.frame = container.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(hosting.view)

        scrollView.addSubview(container)
        scrollView.contentSize = contentSize

        context.coordinator.hostingController = hosting
        context.coordinator.containerView = container
        context.coordinator.scrollView = scrollView
        context.coordinator.baseContentSize = contentSize
        context.coordinator.initialCenterPoint = initialCenterPoint

        let coordinator = context.coordinator
        scrollView.onLayout = { [weak scrollView] in
            guard let scrollView else { return }
            coordinator.applyInitialCenterIfNeeded(in: scrollView)
        }

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale

        let sizeChanged = context.coordinator.baseContentSize != contentSize
        if sizeChanged {
            context.coordinator.baseContentSize = contentSize
            context.coordinator.initialCenterPoint = initialCenterPoint
            context.coordinator.containerView?.frame = CGRect(origin: .zero, size: contentSize)
            scrollView.contentSize = contentSize
        } else {
            context.coordinator.initialCenterPoint = initialCenterPoint
        }

        context.coordinator.hostingController?.rootView = content()

        context.coordinator.applyInitialCenterIfNeeded(in: scrollView)
        context.coordinator.updateContentInsets(for: scrollView)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>?
        weak var scrollView: UIScrollView?
        weak var containerView: UIView?
        var baseContentSize: CGSize = .zero
        var initialCenterPoint: CGPoint = .zero
        var didApplyInitialCenter = false

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            containerView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            updateContentInsets(for: scrollView)
        }

        func applyInitialCenterIfNeeded(in scrollView: UIScrollView) {
            guard !didApplyInitialCenter else { return }
            let bounds = scrollView.bounds.size
            guard bounds.width > 0.5, bounds.height > 0.5 else { return }
            didApplyInitialCenter = true
            applyCenter(initialCenterPoint, zoomScale: scrollView.zoomScale, in: scrollView)
            updateContentInsets(for: scrollView)
        }

        /// Re-centers on a point in **unscaled** content coordinates.
        func applyCenter(_ point: CGPoint, zoomScale: CGFloat, in scrollView: UIScrollView) {
            let bounds = scrollView.bounds.size
            guard bounds.width > 0, bounds.height > 0 else { return }

            let scaledWidth = baseContentSize.width * zoomScale
            let scaledHeight = baseContentSize.height * zoomScale

            var offsetX = point.x * zoomScale - bounds.width / 2
            var offsetY = point.y * zoomScale - bounds.height / 2

            let maxOffsetX = max(0, scaledWidth - bounds.width)
            let maxOffsetY = max(0, scaledHeight - bounds.height)

            offsetX = min(max(0, offsetX), maxOffsetX)
            offsetY = min(max(0, offsetY), maxOffsetY)

            scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
        }

        func updateContentInsets(for scrollView: UIScrollView) {
            guard let container = containerView else { return }
            let subviewSize = container.frame.size
            let scrollViewSize = scrollView.bounds.size
            guard
                subviewSize.width > 0,
                subviewSize.height > 0,
                scrollViewSize.width > 0,
                scrollViewSize.height > 0
            else {
                return
            }

            let verticalPadding: CGFloat
            if subviewSize.height < scrollViewSize.height {
                verticalPadding = (scrollViewSize.height - subviewSize.height) / 2
            } else {
                verticalPadding = 0
            }
            let horizontalPadding: CGFloat
            if subviewSize.width < scrollViewSize.width {
                horizontalPadding = (scrollViewSize.width - subviewSize.width) / 2
            } else {
                horizontalPadding = 0
            }

            let inset = UIEdgeInsets(
                top: verticalPadding,
                left: horizontalPadding,
                bottom: verticalPadding,
                right: horizontalPadding
            )
            if scrollView.contentInset != inset {
                scrollView.contentInset = inset
            }
        }

    }
}

// MARK: - Layout hook

private final class ZoomScrollView: UIScrollView {
    var onLayout: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}
