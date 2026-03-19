import Models
import SwiftUI

@MainActor
struct TradingPostTradeCardView: View {
    let trade: TradingPostTrade
    var viewModel: TradingPostViewModel

    var body: some View {
        let remaining = trade.quantity
        let rarityColor = trade.fromItem.quality.color
        let isOfferExhausted = trade.quantity == 0

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Button {
                    viewModel.showItemDetails(trade.fromItem)
                } label: {
                    ItemView(
                        item: trade.fromItem,
                        quantity: trade.fromQuantity,
                        size: .small
                    )
                }
                .buttonStyle(.plain)

                Image(systemName: "arrow.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)

                Button {
                    viewModel.showItemDetails(trade.toItem)
                } label: {
                    ItemView(
                        item: trade.toItem,
                        quantity: trade.toQuantity,
                        size: .small
                    )
                }
                .buttonStyle(.plain)
            }

            if remaining > 0 {
                HStack {
                    Text("Uses left")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)

                    Text("\(remaining)/\(TradingPostTrade.maxExecutionsPerTrade)")
                        .font(.appMonospaceBadge)
                }
            }

            tradeButton
        }
        .padding(14)
        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(rarityColor.opacity(0.25), lineWidth: 1)
        )
        .opacity(isOfferExhausted ? 0.78 : 1)
    }

    @ViewBuilder
    private var tradeButton: some View {
        let remaining = viewModel.remainingExecutions(for: trade)
        let missing = viewModel.missingFromItemCount(for: trade)
        if trade.quantity == 0 {
            Button(
                action: {},
                label: {
                    Text("Completed")
                        .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.bordered)
            .disabled(true)
        } else {
            Button(
                action: { viewModel.execute(trade: trade) },
                label: {
                    Text(
                        remaining > 0
                            ? "Trade"
                            : (missing > 0 ? "Missing \(missing) items" : "Unavailable")
                    )
                    .frame(maxWidth: .infinity)
                }
            )
            .buttonStyle(.borderedProminent)
            .disabled(remaining == 0)
        }
    }
}
