//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Foundation
import Knit
import SwiftUI

public enum MainPath: CoordinatorPath {
    
    case creation
    
    public var id: String {
        String(describing: self)
    }
}

public struct MainPathRenderer: CoordinatorPathRenderer {
    
    let resolver: BaseResolver
    
    @ViewBuilder
    public func render(path: MainPath, in coordinator: Coordinator) -> some View {
        switch path {
        case .creation:
            CreationView(viewModel: coordinator.apply(resolver.creationViewModel()))
        }
    }
}
