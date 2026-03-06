//Created for Essence Breakdown feature.

import ASKCoordinator
import Knit
import KnitMacros
import SwiftUI

@Observable final class EssenceBreakdownViewModel: CoordinatorViewModel {
    var coordinator: Coordinator?

    /// nil = "All", non-nil = filter by that quality.
    var selectedQualityFilter: ItemQuality?

    @Resolvable<BaseResolver>
    init() {}
}

// MARK: - Computed data

extension EssenceBreakdownViewModel {

    var itemsInScope: [BaseItem] {
        if let quality = selectedQualityFilter {
            return BaseItem.allCases.filter { $0.quality == quality }
        }
        return Array(BaseItem.allCases)
    }

    /// Essence counts in stable order (Essence.allCases), 0 for missing.
    var essenceCounts: [(Essence, Int)] {
        let counts = itemsInScope
            .flatMap(\.essences)
            .reduce(into: [Essence: Int]()) { acc, e in acc[e, default: 0] += 1 }
        return Essence.allCases.map { ($0, counts[$0, default: 0]) }
    }

    var hasAnyCounts: Bool {
        essenceCounts.contains { $0.1 > 0 }
    }
}
