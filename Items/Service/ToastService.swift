//  Created by Alexander Skorulis on 3/3/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import SwiftUI

final class ToastService {
    
    // The place where toasts will be shown
    weak var coordinator: ASKCoordinator.Coordinator?

    @Resolvable<BaseResolver>
    init() {}
    
    func showToast(_ message: String, icon: AnyView? = nil) {
        print("Toast: \(message)")
        guard let coordinator else {
            return
        }
        coordinator.custom(overlay: .toast, MainPath.toast(icon, message))
    }
}
