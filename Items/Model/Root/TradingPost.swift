import Foundation
import Models

/// Persisted Trading Post state.
/// Keeps the currently offered trades stable when navigating away and back.
public struct TradingPost: Codable, Equatable {
    public var trades: [TradingPostTrade] = []
    /// The hour start (local time) when the Trading Post was last auto-refreshed for free.
    /// Used to keep refresh behavior consistent across view model instances and app sessions.
    public var lastAutoRefreshHour: Date? = nil

    public init(
        trades: [TradingPostTrade] = [],
        lastAutoRefreshHour: Date? = nil
    ) {
        self.trades = trades
        self.lastAutoRefreshHour = lastAutoRefreshHour
    }
}

public struct TradingPostTrade: Codable, Identifiable, Hashable, Equatable {
    public static let maxExecutionsPerTrade = 5

    public var id: UUID
    public let fromItem: BaseItem
    public let toItem: BaseItem

    /// Remaining executions for this trade offer (decrements each time the trade is made).
    public var quantity: Int

    public let fromQuantity: Int
    public let toQuantity: Int

    public init(
        id: UUID = UUID(),
        fromItem: BaseItem,
        toItem: BaseItem,
        quantity: Int = TradingPostTrade.maxExecutionsPerTrade,
        fromQuantity: Int,
        toQuantity: Int,
    ) {
        self.id = id
        self.quantity = quantity
        self.fromQuantity = fromQuantity
        self.toQuantity = toQuantity
        self.fromItem = fromItem
        self.toItem = toItem
    }

}
