import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models

@Observable
final class TradingPostViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    private let mainStore: MainStore
    private let warehouseService: WarehouseService

    private var cancellables: Set<AnyCancellable> = []

    private let maxExecutionsPerTrade = 5
    private let refreshCostSigil = 1

    // Fixed exchange preset for the first implementation.
    private let fromQuantity = 5
    private let toQuantity = 2

    var warehouse: Warehouse
    var trades: [Trade] = []

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        warehouseService: WarehouseService
    ) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        self.warehouse = mainStore.warehouse

        mainStore.$warehouse
            .sink { [unowned self] in
                self.warehouse = $0
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        if trades.isEmpty {
            refreshTrades(consumeSigil: false)
        }
    }

    var merchantSigilCount: Int {
        warehouse.quantity(.merchantSigil)
    }

    var canRefreshTrades: Bool {
        merchantSigilCount >= refreshCostSigil
    }

    func refreshTrades() {
        refreshTrades(consumeSigil: true)
    }

    private func refreshTrades(consumeSigil: Bool) {
        if consumeSigil {
            guard canRefreshTrades else { return }
            warehouseService.remove(item: .merchantSigil, quantity: refreshCostSigil)
        }

        trades = generateTrades()
    }

    func remainingExecutions(for trade: Trade) -> Int {
        let available = warehouse.quantity(trade.fromItem) / fromQuantity
        return min(maxExecutionsPerTrade, max(0, available))
    }

    func canExecute(trade: Trade) -> Bool {
        remainingExecutions(for: trade) > 0
    }

    func execute(trade: Trade) {
        guard canExecute(trade: trade) else { return }

        warehouseService.remove(item: trade.fromItem, quantity: fromQuantity)
        warehouseService.add(item: trade.toItem, count: toQuantity)
    }

    func showHelp() {
        coordinator?.custom(
            overlay: .card,
            MainPath.dialog(HelpStrings.tradingPost)
        )
    }

    // MARK: - Trade generation

    struct Trade: Identifiable, Hashable {
        let id = UUID()
        let fromItem: BaseItem
        let toItem: BaseItem
    }

    private func generateTrades() -> [Trade] {
        let itemsByQuality = Dictionary(grouping: BaseItem.allCases, by: \.quality)
        let qualitiesWithPairs = ItemQuality.allCases.filter {
            (itemsByQuality[$0]?.count ?? 0) >= 2
        }

        guard let qualityPool = qualitiesWithPairs.randomElement() else {
            return []
        }

        func makeRandomTrade(preferExecutableFromItems: Bool) -> Trade? {
            let quality = qualitiesWithPairs.randomElement() ?? qualityPool
            guard let candidatesInTier = itemsByQuality[quality], candidatesInTier.count >= 2 else {
                return nil
            }

            let executableFromItems = candidatesInTier.filter { warehouse.quantity($0) >= fromQuantity }
            let fromPool = (preferExecutableFromItems && !executableFromItems.isEmpty)
                ? executableFromItems
                : candidatesInTier

            guard let from = fromPool.randomElement() else { return nil }
            let toCandidates = candidatesInTier.filter { $0 != from }
            guard let to = toCandidates.randomElement() else { return nil }
            return Trade(fromItem: from, toItem: to)
        }

        var result: [Trade] = []
        var keys = Set<String>()

        // First pass: prefer from-items we can actually execute.
        var attempts = 0
        while result.count < 3, attempts < 500 {
            attempts += 1
            guard let trade = makeRandomTrade(preferExecutableFromItems: true) else { continue }
            let key = "\(trade.fromItem.rawValue)->\(trade.toItem.rawValue)"
            guard !keys.contains(key) else { continue }
            keys.insert(key)
            result.append(trade)
        }

        // Second pass: fill remaining trades even if not currently executable.
        attempts = 0
        while result.count < 3, attempts < 500 {
            attempts += 1
            guard let trade = makeRandomTrade(preferExecutableFromItems: false) else { continue }
            let key = "\(trade.fromItem.rawValue)->\(trade.toItem.rawValue)"
            guard !keys.contains(key) else { continue }
            keys.insert(key)
            result.append(trade)
        }

        return Array(result.prefix(3))
    }
}

