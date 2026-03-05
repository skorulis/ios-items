//Created by Alexander Skorulis on 17/2/2026.

import ASKCoordinator
import Knit
import SwiftUI

extension CoordinatorView {
    func withRenderers(resolver: BaseResolver) -> Self {
        self.with(renderer: resolver.mainPathRenderer())
            .with(renderer: CircularPathRenderer(mainPathRenderer: resolver.mainPathRenderer()))
        .with(overlay: .card) { view, _ in
            AnyView(CardPathWrapper { view })
        }
        .with(overlay: .circularReveal) { view, path in
            AnyView(CircularRevealPathWrapper(path: path) { view })
        }
        .with(overlay: .toast) { view, _ in
            AnyView(ToastPathWrapper { view })
        }
    }
}
