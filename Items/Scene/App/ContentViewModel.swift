//Created by Alexander Skorulis on 10/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ContentViewModel {
    
    private(set) var showingResearch: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        mainStore.$warehouse.sink { warehouse in
            self.showingResearch = warehouse.totalItemsCollected >= 10
        }
        .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ContentViewModel {
    
}
