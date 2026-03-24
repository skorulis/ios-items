// Created by Cursor on 24/3/2026.

import SwiftUI

/// Pinch to zoom, drag to pan, double-tap to reset. Adapted from
/// [Building a Reusable Zoomable and Pannable View in SwiftUI](https://medium.com/@gauravharkhani01/building-a-reusable-zoomable-and-pannable-view-in-swiftui-7f17f41e23c9)
/// with fixed-size content, optional zoom-out (minScale below 1), and correct pinch scale accumulation.
struct ZoomablePannableView<Content: View>: View {

    let minScale: CGFloat
    let maxScale: CGFloat
    let contentSize: CGSize
    var restScale: CGFloat = 1
    var restOffset: CGSize = .zero
    @ViewBuilder private let content: () -> Content

    @State private var scale: CGFloat
    @State private var pinchBaseScale: CGFloat
    @State private var offset: CGSize
    @State private var dragStartOffset: CGSize

    init(
        minScale: CGFloat = 0.25,
        maxScale: CGFloat = 4,
        contentSize: CGSize,
        restScale: CGFloat = 1,
        restOffset: CGSize = .zero,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.contentSize = contentSize
        self.restScale = restScale
        self.restOffset = restOffset
        self.content = content
        _scale = State(initialValue: restScale)
        _pinchBaseScale = State(initialValue: restScale)
        _offset = State(initialValue: restOffset)
        _dragStartOffset = State(initialValue: restOffset)
    }

    var body: some View {
        GeometryReader { geometry in
            let viewport = geometry.size
            ZStack {
                content()
                    .frame(width: contentSize.width, height: contentSize.height)
                    .scaleEffect(scale)
                    .offset(offset)
            }
            .frame(width: viewport.width, height: viewport.height)
            .contentShape(Rectangle())
            .gesture(combinedGesture(viewport: viewport))
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut) {
                    scale = restScale
                    pinchBaseScale = restScale
                    offset = restOffset
                    dragStartOffset = restOffset
                }
            }
            .animation(.easeInOut, value: scale)
        }
    }

    private func combinedGesture(viewport: CGSize) -> some Gesture {
        let drag = DragGesture(minimumDistance: 8)
            .onChanged { gesture in
                let proposed = CGSize(
                    width: dragStartOffset.width + gesture.translation.width,
                    height: dragStartOffset.height + gesture.translation.height
                )
                offset = calculateBoundedOffset(proposed, viewport: viewport)
            }
            .onEnded { _ in
                dragStartOffset = offset
            }

        let pinch = MagnificationGesture()
            .onChanged { value in
                let next = min(maxScale, max(minScale, pinchBaseScale * value))
                scale = next
                offset = calculateBoundedOffset(offset, viewport: viewport)
            }
            .onEnded { _ in
                pinchBaseScale = scale
                offset = calculateBoundedOffset(offset, viewport: viewport)
                dragStartOffset = offset
            }

        return drag.simultaneously(with: pinch)
    }

    private func calculateBoundedOffset(_ proposed: CGSize, viewport: CGSize) -> CGSize {
        guard viewport.width > 1, viewport.height > 1 else { return proposed }
        let scaledWidth = contentSize.width * scale
        let scaledHeight = contentSize.height * scale
        let maxOffsetX = max(0, (scaledWidth - viewport.width) / 2)
        let maxOffsetY = max(0, (scaledHeight - viewport.height) / 2)
        let boundedX = min(maxOffsetX, max(-maxOffsetX, proposed.width))
        let boundedY = min(maxOffsetY, max(-maxOffsetY, proposed.height))
        return CGSize(width: boundedX, height: boundedY)
    }
}
