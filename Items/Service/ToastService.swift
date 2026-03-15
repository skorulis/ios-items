//  Created by Alexander Skorulis on 3/3/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import SwiftUI

@MainActor
final class ToastService {

    private struct PendingToast {
        let message: String
        let icon: AnyView?
        let id: UUID
    }

    // The place where toasts will be shown
    weak var coordinator: ASKCoordinator.Coordinator?

    private var pendingToasts: [PendingToast] = []

    @Resolvable<BaseResolver>
    init() {}

    func showToast(_ message: String, icon: AnyView? = nil) {
        print("Toast: \(message)")
        let toast = PendingToast(message: message, icon: icon, id: UUID())
        pendingToasts.append(toast)
        if pendingToasts.count == 1 {
            presentCurrentToast()
        }
    }

    /// Called by ToastPathWrapper when the current toast is dismissed so the next can be shown.
    func toastDidDismiss(id: String) {
        pendingToasts.removeAll(where: { $0.id.uuidString == id})
        if !pendingToasts.isEmpty {
            presentCurrentToast()
        }
    }

    private func presentCurrentToast() {
        guard let coordinator, let next = pendingToasts.first else {
            return
        }
        coordinator.custom(overlay: .toast, MainPath.toast(next.icon, next.message, next.id))
    }
}
