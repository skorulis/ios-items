// Created for game statistics screen.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models

@MainActor
final class GameStatisticsViewModel: ObservableObject, CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    @Published private(set) var statistics: Statistics
    @Published private(set) var lab: Laboratory
    @Published private(set) var achievements: Achievements
    @Published private(set) var warehouse: Warehouse
    @Published private(set) var portalUpgrades: PortalUpgrades

    private let mainStore: MainStore
    private var cancellables = Set<AnyCancellable>()

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.statistics = mainStore.statistics
        self.lab = mainStore.lab
        self.achievements = mainStore.achievements
        self.warehouse = mainStore.warehouse
        self.portalUpgrades = mainStore.portalUpgrades
        mainStore.$statistics
            .sink { [weak self] in self?.statistics = $0 }
            .store(in: &cancellables)
        mainStore.$lab
            .sink { [weak self] in self?.lab = $0 }
            .store(in: &cancellables)
        mainStore.$achievements
            .sink { [weak self] in self?.achievements = $0 }
            .store(in: &cancellables)
        mainStore.$warehouse
            .sink { [weak self] in self?.warehouse = $0 }
            .store(in: &cancellables)
        mainStore.$portalUpgrades
            .sink { [weak self] in self?.portalUpgrades = $0 }
            .store(in: &cancellables)
    }

    private var isResearchUnlocked: Bool {
        portalUpgrades.purchased.contains(.researchLab)
    }

    /// Rows for the stats table: display name and formatted value.
    var statRows: [(name: String, value: String)] {
        var rows: [(name: String, value: String)] = [
            ("Items created", formatCount(statistics.itemsCreated)),
            ("Multiple item creations", formatCount(statistics.multipleItemCreations)),
            ("Items sacrificed", formatCount(statistics.itemsSacrificed)),
            ("Number of items discovered", formatCount(Int64(itemsDiscoveredCount))),
            ("Number of achievements unlocked", formatCount(Int64(achievementsUnlockedCount)))
        ]
        if isResearchUnlocked {
            rows.append(("Total levels of research", formatCount(Int64(lab.totalLevels))))
            rows.append(("Max level of research", formatCount(Int64(lab.maxResearchLevel))))
        }
        return rows
    }

    private var itemsDiscoveredCount: Int {
        BaseItem.allCases.filter { warehouse.hasDiscovered($0) }.count
    }

    private var achievementsUnlockedCount: Int {
        achievements.unlocked.count
    }

    private func formatCount(_ n: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}
