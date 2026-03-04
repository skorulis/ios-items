//Created by Alexander Skorulis on 20/2/2026.

import SwiftUI

public struct ChildFrameReader<Content: View>: View {
    @Binding var frame: CGRect
    let coordinateSpace: CoordinateSpace
    let content: () -> Content

    public init(
        frame: Binding<CGRect>,
        coordinateSpace: CoordinateSpace = .global,
        content: @escaping () -> Content
    ) {
        _frame = frame
        self.coordinateSpace = coordinateSpace
        self.content = content
    }

    public var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: FramePreferenceKey.self, value: proxy.frame(in: coordinateSpace))
                    }
                )
        }
        .onPreferenceChange(FramePreferenceKey.self) { preferences in
            self.frame = preferences
        }
    }
}

public extension View {
    func readFrame(frame: Binding<CGRect>, coordinateSpace: CoordinateSpace = .global) -> some View {
        ChildFrameReader(frame: frame, coordinateSpace: coordinateSpace, content: { self })
    }
}

struct FramePreferenceKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
