//Created for game statistics screen.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros

@MainActor
final class GameStatisticsViewModel: ObservableObject, CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    @Published private(set) var statistics: Statistics

    private let mainStore: MainStore
    private var cancellables = Set<AnyCancellable>()

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.statistics = mainStore.statistics
        mainStore.$statistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.statistics = $0 }
            .store(in: &cancellables)
    }

    /// Rows for the stats table: display name and formatted value.
    var statRows: [(name: String, value: String)] {
        [
            ("Items created", formatCount(statistics.itemsCreated)),
            ("Double creations", formatCount(statistics.doubleItemCreations)),
            ("Items sacrificed", formatCount(statistics.itemsSacrificed)),
        ]
    }

    private func formatCount(_ n: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}
