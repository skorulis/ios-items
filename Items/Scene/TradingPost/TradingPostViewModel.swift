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
        if mainStore.tradingPost.trades.isEmpty {
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

        let newTrades = tradingPostService.generateTrades()

        // Update persisted TradingPost state so trades remain stable
        // between view model instances.
        var tradingPost = mainStore.tradingPost
        tradingPost.trades = newTrades
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
}
