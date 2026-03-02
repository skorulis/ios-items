//Created by Alexander Skorulis on 3/3/2026.

import ASKCoordinator
import Knit
import SwiftUI

extension CustomOverlay.Name {
    static let toast = CustomOverlay.Name("toast")
}

struct ToastPathWrapper<Content: View>: View {
    @State var isVisible: Bool = false
    let content: () -> Content
    
    @Environment(\.dismissCustomOverlay) private var onDismiss
    
    var body: some View {
        ZStack {
            if isVisible {
                VStack {
                    Spacer()
                    Toast(content: content)
                }
                .transition(.opacity)
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                    } catch {
                        print("Task cancelled")
                    }
                    onDismiss()
                }
            }
        }
        .padding(.bottom, 64) // Space for tab bar
        .animation(.easeInOut(duration: 0.15), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
    
    private func maybeDismiss() {
        onDismiss()
    }
    
}
