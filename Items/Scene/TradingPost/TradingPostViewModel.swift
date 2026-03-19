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

    private let baseRefreshCostSigil = 1

    private let tradingPostService: TradingPostService

    var warehouse: Warehouse
    var trades: [TradingPostTrade] = []
    private var manualRefreshCount: Int = 0

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
        self.manualRefreshCount = mainStore.tradingPost.manualRefreshCount
        self.tradingPostService = tradingPostService

        mainStore.$warehouse
            .sink { [unowned self] in
                self.warehouse = $0
            }
            .store(in: &cancellables)

        mainStore.$tradingPost
            .sink { [unowned self] in
                self.trades = $0.trades
                self.manualRefreshCount = $0.manualRefreshCount
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        let now = Date()
        let currentHour = hourStart(for: now)

        let isAutoRefreshForThisHour = mainStore.tradingPost.lastAutoRefreshHour == currentHour

        // Refresh immediately if the list is empty.
        // Only reset manual-refresh cost escalation when we're actually doing the hourly auto refresh.
        if mainStore.tradingPost.trades.isEmpty || !isAutoRefreshForThisHour {
            tradingPostService.refreshTrades(manual: false)
        }

        nextAutoRefreshHourStart = tradingPostService.nextHourStart(from: now)
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

    var currentRefreshCostSigil: Int {
        baseRefreshCostSigil + manualRefreshCount
    }

    var canRefreshTrades: Bool {
        merchantSigilCount >= currentRefreshCostSigil
    }

    func refreshTrades() {
        tradingPostService.refreshTrades(manual: true)
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
            nextAutoRefreshHourStart = tradingPostService.nextHourStart(from: now)
            return
        }

        // When the fixed countdown hits/passes the target hour, refresh for free (once per hour).
        guard now >= next else { return }

        let currentHour = hourStart(for: now)
        guard mainStore.tradingPost.lastAutoRefreshHour != currentHour else { return }

        // This is always a free refresh (hourly schedule).
        tradingPostService.refreshTrades(manual: false)

        // Roll the countdown forward; the next tick will update the displayed remaining time.
        nextAutoRefreshHourStart = tradingPostService.nextHourStart(from: now)
        secondsUntilNextAutoRefresh = 0
    }
}
