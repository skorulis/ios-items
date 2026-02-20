//Created by Alexander Skorulis on 20/2/2026.

import SwiftUI

public struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    
    public init(size: Binding<CGSize>,
                content: @escaping () -> Content
    ) {
        _size = size
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

public extension View {
    func readSize(size: Binding<CGSize>) -> some View {
        ChildSizeReader(size: size, content: {self})
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
