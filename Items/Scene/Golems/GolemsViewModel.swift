import ASKCoordinator
import ASKCore
import Knit
import KnitMacros
import SwiftUI

@Observable final class GolemsViewModel: CoordinatorViewModel {

    weak var coordinator: ASKCoordinator.Coordinator?

    @Resolvable<BaseResolver>
    init() {}

    func onAppear() {
        // No-op for now (content will be added later).
    }
}
