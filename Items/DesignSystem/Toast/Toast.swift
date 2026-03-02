//Created by Alexander Skorulis on 3/3/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct Toast<Content: View> {
    
    private let content: Content
    
    init(content: @escaping () -> Content) {
        self.content = content()
    }
    
}

// MARK: - Rendering

extension Toast: View {
    
    var body: some View {
        content
            .foregroundStyle(Color.white)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(background)
            .padding(.horizontal, 24)
    }
    
    private var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white, lineWidth: 2)
        }
    }
}

struct DefaultToastContent: View {
    
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
        }
    }
}

extension Toast where Content == DefaultToastContent {
    
    init(text: String) {
        self.init {
            DefaultToastContent(text: text)
        }
    }
}

// MARK: - Previews

#Preview {
    VStack {
        Toast(text: "Test123")
    }
    .frame(maxHeight: .infinity)
    .background(Color.black)
    
}


