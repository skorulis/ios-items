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
    
    let icon: AnyView?
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                icon
            }
            Text(text)
            Spacer()
        }
    }
}

extension Toast where Content == DefaultToastContent {
    
    init(icon: AnyView? = nil, text: String) {
        self.init {
            DefaultToastContent(icon: icon, text: text)
        }
    }
}

// MARK: - Previews

#Preview {
    VStack {
        Toast(text: "Test123")
        Toast(
            icon: AnyView(AvatarView(text: "AB", image: nil, border: .black, size: .small)),
            text: "Test123"
        )
    }
    .frame(maxHeight: .infinity)
    .background(Color.black)
    
}


