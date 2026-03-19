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

    private let refreshCostSigil = 1

    private let tradingPostService: TradingPostService

    var warehouse: Warehouse
    var trades: [TradingPostTrade] = []

    /// Countdown to the next scheduled free refresh (every hour on the hour mark).
    var secondsUntilNextAutoRefresh: Int = 0

    private var autoRefreshTimer: AnyCancellable?
    private var nextAutoRefreshHourStart: Date?

    @Resolvable<BaseResolver>
    init(
        mainStore: MainStore,
        warehouseService: WarehouseService,
        tradingPostService: TradingPostService,
    ) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
        self.warehouse = mainStore.warehouse
        self.trades = mainStore.tradingPost.trades
        self.tradingPostService = tradingPostService

        mainStore.$warehouse
            .sink { [unowned self] in
                self.warehouse = $0
            }
            .store(in: &cancellables)

        mainStore.$tradingPost
            .sink { [unowned self] in
                self.trades = $0.trades
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        let now = Date()
        let currentHour = hourStart(for: now)

        // If the hour hasn't been auto-refreshed yet (or the list is empty), refresh immediately for free.
        if mainStore.tradingPost.trades.isEmpty || mainStore.tradingPost.lastAutoRefreshHour != currentHour {
            refreshTrades(consumeSigil: false, autoRefreshHour: currentHour)
        }

        nextAutoRefreshHourStart = nextHourStart(from: now)
        updateCountdown(now: now)
        startAutoRefreshCountdown()
    }

    func onDisappear() {
        autoRefreshTimer?.cancel()
        autoRefreshTimer = nil
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

    private func refreshTrades(consumeSigil: Bool, autoRefreshHour: Date? = nil) {
        if consumeSigil {
            guard canRefreshTrades else { return }
            warehouseService.remove(item: .merchantSigil, quantity: refreshCostSigil)
        }

        let newTrades = tradingPostService.generateTrades()

        // Update persisted TradingPost state so trades remain stable
        // between view model instances.
        var tradingPost = mainStore.tradingPost
        tradingPost.trades = newTrades
        if let autoRefreshHour {
            tradingPost.lastAutoRefreshHour = autoRefreshHour
        }
        mainStore.tradingPost = tradingPost
    }

    func remainingExecutions(for trade: TradingPostTrade) -> Int {
        let fromInventory = warehouse.quantity(trade.fromItem) / trade.fromQuantity
        return min(max(0, trade.quantity), max(0, fromInventory))
    }

    func canExecute(trade: TradingPostTrade) -> Bool {
        remainingExecutions(for: trade) > 0
    }

    func execute(trade: TradingPostTrade) {
        guard canExecute(trade: trade) else { return }
        tradingPostService.executeTrade(tradeID: trade.id)
    }

    func showHelp() {
        coordinator?.custom(
            overlay: .card,
            MainPath.dialog(HelpStrings.tradingPost)
        )
    }

    func showItemDetails(_ item: BaseItem) {
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }

    // MARK: - Hourly auto refresh

    private func hourStart(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour], from: date)
        return cal.date(from: comps) ?? date
    }

    private func nextHourStart(from date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .hour, value: 1, to: hourStart(for: date)) ?? date.addingTimeInterval(3600)
    }

    private func updateCountdown(now: Date) {
        guard let next = nextAutoRefreshHourStart else { return }
        secondsUntilNextAutoRefresh = max(0, Int(ceil(next.timeIntervalSince(now))))
    }

    private func startAutoRefreshCountdown() {
        autoRefreshTimer?.cancel()

        autoRefreshTimer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tickAutoRefresh()
            }
    }

    private func tickAutoRefresh() {
        let now = Date()
        updateCountdown(now: now)

        guard let next = nextAutoRefreshHourStart else {
            nextAutoRefreshHourStart = nextHourStart(from: now)
            return
        }

        // When the fixed countdown hits/passes the target hour, refresh for free (once per hour).
        guard now >= next else { return }

        let currentHour = hourStart(for: now)
        guard mainStore.tradingPost.lastAutoRefreshHour != currentHour else { return }

        // This is always a free refresh (hourly schedule).
        refreshTrades(consumeSigil: false, autoRefreshHour: currentHour)

        // Roll the countdown forward; the next tick will update the displayed remaining time.
        nextAutoRefreshHourStart = nextHourStart(from: now)
        secondsUntilNextAutoRefresh = 0
    }
}
