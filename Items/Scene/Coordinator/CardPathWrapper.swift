//Created by Alexander Skorulis on 14/2/2026.

import ASKCoordinator
import Foundation
import SwiftUI

struct CardPathWrapper<Content: View>: View {
    let content: () -> Content
    
    @Environment(\.dismissCustomOverlay) private var onDismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .onTapGesture(perform: maybeDismiss)
                .ignoresSafeArea()
            
            content()
                .background(CardBackground())
                .padding(16)
        }
    }
    
    private func maybeDismiss() {
        onDismiss()
    }
    
}

extension CustomOverlay.Name {
    // A card in the center of the screen
    static let card = CustomOverlay.Name("card")
}
