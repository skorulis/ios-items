//Created by Alexander Skorulis on 21/2/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class EncyclopediaViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?
    
    let entry: EncyclopediaEntry
    
    @Resolvable<BaseResolver>
    init(@Argument entry: EncyclopediaEntry) {
        self.entry = entry
    }
}

// MARK: - Logic

extension EncyclopediaViewModel {
    
    var backAction: (() -> Void)? {
        guard let coordinator,
              coordinator.canPop
        else { return nil }
        
        return { coordinator.pop() }
    }
    
    func showChild(entry: EncyclopediaEntry) {
        coordinator?.push(MainPath.encyclopediaEntry(entry))
    }
    
}
