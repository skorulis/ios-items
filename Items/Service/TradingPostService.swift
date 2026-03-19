import Foundation
import Knit
import KnitMacros
import Models

/// Generates randomized Trading Post trade offers.
/// Kept out of the view model so the UI just consumes persisted offers.
final class TradingPostService {
    private let baseTradeCount = 3
    private let fromQuantity = 5
    private let toQuantity = 2

    private let mainStore: MainStore
    private let warehouseService: WarehouseService

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, warehouseService: WarehouseService) {
        self.mainStore = mainStore
        self.warehouseService = warehouseService
    }

    private func tradeCountForCurrentUpgrades() -> Int {
        let purchased = mainStore.portalUpgrades.purchased
        let extraTrades = [
            purchased.contains(.tradingPostLevel2) ? 1 : 0,
            purchased.contains(.tradingPostLevel3) ? 1 : 0
        ].reduce(0, +)
        return baseTradeCount + extraTrades
    }
    
    func refreshTrades(manual: Bool) {
        var tradingPost = mainStore.tradingPost
        
        if manual {
            let cost = mainStore.tradingPost.manualRefreshCount + 1
            guard mainStore.warehouse.quantity(.merchantSigil) > cost else { return }
            warehouseService.remove(item: .merchantSigil, quantity: cost)
            mainStore.tradingPost.manualRefreshCount += 1
        } else  {
            // Hourly scheduled refresh: free, resets manual refresh escalation.
            tradingPost.manualRefreshCount = 0
            tradingPost.lastAutoRefreshHour = hourStart(for: Date())
        }
        tradingPost.trades = generateTrades()
        mainStore.tradingPost = tradingPost
    }
    
    func nextHourStart(from date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .hour, value: 1, to: hourStart(for: date)) ?? date.addingTimeInterval(3600)
    }
    
    func hourStart(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day, .hour], from: date)
        return cal.date(from: comps) ?? date
    }

    func generateTrades() -> [TradingPostTrade] {
        let tradeCount = tradeCountForCurrentUpgrades()
        let discovered = BaseItem.allCases.filter { mainStore.warehouse.hasDiscovered($0) }
        let itemsByQuality = Dictionary(grouping: discovered, by: \.quality)
        let qualitiesWithPairs = ItemQuality.allCases.filter {
            (itemsByQuality[$0]?.count ?? 0) >= 2
        }

        guard let qualityPool = qualitiesWithPairs.randomElement() else {
            return []
        }

        func makeRandomTrade(preferExecutableFromItems: Bool) -> TradingPostTrade? {
            let quality = qualitiesWithPairs.randomElement() ?? qualityPool
            guard let candidatesInTier = itemsByQuality[quality], candidatesInTier.count >= 2 else {
                return nil
            }

            let executableFromItems = candidatesInTier.filter { mainStore.warehouse.quantity($0) >= fromQuantity }
            let fromPool = (preferExecutableFromItems && !executableFromItems.isEmpty)
                ? executableFromItems
                : candidatesInTier

            guard let from = fromPool.randomElement() else { return nil }
            let toCandidates = candidatesInTier.filter { $0 != from }
            guard let to = toCandidates.randomElement() else { return nil }

            return TradingPostTrade(
                fromItem: from,
                toItem: to,
                quantity: TradingPostTrade.maxExecutionsPerTrade,
                fromQuantity: self.fromQuantity,
                toQuantity: self.toQuantity,
            )
        }

        var result: [TradingPostTrade] = []
        var keys = Set<String>()

        // First pass: prefer from-items we can actually execute.
        var attempts = 0
        while result.count < tradeCount, attempts < 500 {
            attempts += 1
            guard let trade = makeRandomTrade(preferExecutableFromItems: true) else { continue }
            let key = "\(trade.fromItem.rawValue)->\(trade.toItem.rawValue)"
            guard !keys.contains(key) else { continue }
            keys.insert(key)
            result.append(trade)
        }

        // Second pass: fill remaining trades even if not currently executable.
        attempts = 0
        while result.count < tradeCount, attempts < 500 {
            attempts += 1
            guard let trade = makeRandomTrade(preferExecutableFromItems: false) else { continue }
            let key = "\(trade.fromItem.rawValue)->\(trade.toItem.rawValue)"
            guard !keys.contains(key) else { continue }
            keys.insert(key)
            result.append(trade)
        }

        return Array(result.prefix(tradeCount))
    }

    func executeTrade(tradeID: UUID) {
        var tradingPost = mainStore.tradingPost
        guard let tradeIndex = tradingPost.trades.firstIndex(where: { $0.id == tradeID }) else {
            return
        }

        // Trade is only executable if it still has remaining quantity and the player can pay.
        let currentTrade = tradingPost.trades[tradeIndex]
        guard currentTrade.quantity > 0 else { return }
        guard mainStore.warehouse.quantity(currentTrade.fromItem) >= currentTrade.fromQuantity else { return }

        // Apply the exchange.
        warehouseService.remove(item: currentTrade.fromItem, quantity: currentTrade.fromQuantity)
        warehouseService.add(item: currentTrade.toItem, count: currentTrade.toQuantity)

        // Decrement the built-in remaining executions and persist.
        tradingPost.trades[tradeIndex].quantity -= 1
        mainStore.tradingPost = tradingPost // Triggers persistence and UI updates.

        // Track statistics for achievements and the stats screen.
        mainStore.statistics.tradesCompleted += 1
    }
}
