//Created by Alexander Skorulis on 17/2/2026.

import ASKCoordinator
import Knit
import SwiftUI

extension CoordinatorView {
    func withRenderers(resolver: BaseResolver) -> Self {
        self.with(renderer: resolver.mainPathRenderer())
        .with(overlay: .card) { view in
            AnyView(CardPathWrapper { view })
        }
    }
}
