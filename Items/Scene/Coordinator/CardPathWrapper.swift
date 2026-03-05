//Created by Alexander Skorulis on 14/2/2026.

import ASKCoordinator
import Foundation
import SwiftUI

struct CardPathWrapper<Content: View>: View {
    let content: () -> Content
    
    @Environment(\.dismissCustomOverlay) private var onDismiss
    @State private var isVisible: Bool = false
    @State private var animatingOut: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .onTapGesture(perform: maybeDismiss)
                .ignoresSafeArea()
                .opacity(animatingOut ? 0 : 1)
            
            content()
                .background(CardBackground())
                .padding(16)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.9)
                .onAppear {
                    withAnimation(.snappy(duration: 0.25)) {
                        isVisible = true
                    }
                }
        }
    }
    
    private func maybeDismiss() {
        withAnimation(.snappy(duration: 0.25)) {
            isVisible = false
            animatingOut = true
        } completion: {
            onDismiss()
        }
    }
    
}

extension CustomOverlay.Name {
    // A card in the center of the screen
    static let card = CustomOverlay.Name("card")
}
