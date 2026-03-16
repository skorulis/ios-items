//Created by Alexander Skorulis on 3/3/2026.

import ASKCoordinator
import Knit
import SwiftUI

extension CustomOverlay.Name {
    static let toast = CustomOverlay.Name("toast")
}

struct ToastPathWrapper<Content: View>: View {
    @State var isVisible: Bool = false
    let toastService: ToastService?
    let id: String
    let content: () -> Content

    @Environment(\.dismissCustomOverlay) private var onDismiss

    var body: some View {
        ZStack {
            if isVisible {
                VStack {
                    Button(action: dismissToast) {
                        Toast(content: content)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .transition(.opacity)
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                    } catch {
                        print("Task cancelled")
                    }
                    dismissToast()
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }

    private func dismissToast() {
        onDismiss()
        toastService?.toastDidDismiss(id: id)
    }
}

#Preview {
    ToastPathWrapper(
        isVisible: true,
        toastService: nil,
        id: "",
        content: { Text("Toast") },
    )
}
