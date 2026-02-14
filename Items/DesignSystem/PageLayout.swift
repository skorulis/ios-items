//Created by Alexander Skorulis on 1/12/2025.

import Foundation
import SwiftUI

public struct PageLayout<TitleBar: View, Content: View, Footer: View>: View {
    
    private let titleBar: () -> TitleBar
    private let content: () -> Content
    private let footer: () -> Footer
    
    public init(
        titleBar: @escaping () -> TitleBar,
        content: @escaping () -> Content,
        footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.titleBar = titleBar
        self.content = content
        self.footer = footer
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            titleBar()
            ScrollView {
                Spacer()
                    .frame(height: 24)
                content()
            }
            .background(Color.white)
            footer()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .navigationBarHidden(true)
    }
}

