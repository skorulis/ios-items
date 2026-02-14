//Created by Alexander Skorulis on 14/2/2026.

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
        }
    }
    
    private func maybeDismiss() {
        onDismiss()
    }
    
}

