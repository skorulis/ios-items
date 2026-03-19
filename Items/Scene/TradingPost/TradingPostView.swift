import ASKCoordinator
import Knit
import Models
import SwiftUI
import Foundation

@MainActor
struct TradingPostView: View {
    @State var viewModel: TradingPostViewModel

    @Environment(\.dismissCircularReveal) private var dismissCircularReveal

    /// Trades still have executions remaining on the offer (`quantity > 0`).
    private var activeTrades: [TradingPostTrade] {
        viewModel.trades.filter { $0.quantity > 0 }
    }

    /// Trades whose offer uses are fully exhausted (`quantity == 0`).
    private var completedTrades: [TradingPostTrade] {
        viewModel.trades.filter { $0.quantity == 0 }
    }

    /// Changes when any trade crosses between active and complete; drives layout animation.
    private var tradeListAnimationSignature: String {
        viewModel.trades
            .map { "\($0.id.uuidString):\($0.quantity)" }
            .sorted()
            .joined(separator: "|")
    }

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    private var titleBar: some View {
        TitleBar(
            title: "Trading Post",
            backAction: {
                if let dismissCircularReveal {
                    dismissCircularReveal()
                } else {
                    viewModel.coordinator?.pop()
                }
            },
            leadingStyle: .close,
            trailing: {
                Button(action: viewModel.showHelp) {
                    Image(systemName: "questionmark.app")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.black)
                }
            }
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            sigilAndRefreshRow

            Text("Trades")
                .font(.appSectionTitle)

            autoRefreshCountdownRow

            tradesList
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var autoRefreshCountdownRow: some View {
        HStack {
            Text("Refreshes in \(formatSeconds(viewModel.secondsUntilNextAutoRefresh))")
                .font(.appCaption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let remainingSeconds = clamped % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private var sigilAndRefreshRow: some View {
        HStack(spacing: 12) {
            ItemView(
                item: .merchantSigil,
                quantity: viewModel.merchantSigilCount > 0 ? viewModel.merchantSigilCount : nil,
                size: .small
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Merchant Sigil")
                    .font(.appSubheadline.weight(.semibold))
                Text(
                    "Refresh costs \(viewModel.currentRefreshCostSigil) "
                        + (viewModel.currentRefreshCostSigil == 1 ? "sigil" : "sigils")
                )
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button(action: viewModel.refreshTrades) {
                Text("Refresh")
                    .frame(minWidth: 84)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canRefreshTrades)
        }
        .padding(12)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    private var tradesList: some View {
        VStack(spacing: 12) {
            ForEach(activeTrades) { trade in
                TradingPostTradeCardView(trade: trade, viewModel: viewModel)
                    .id(trade.id)
            }

            if !completedTrades.isEmpty {
                Text("Complete")
                    .font(.appSectionTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)

                ForEach(completedTrades) { trade in
                    TradingPostTradeCardView(trade: trade, viewModel: viewModel)
                        .id(trade.id)
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: tradeListAnimationSignature)
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.mainStore().warehouse.add(item: .rock, count: 15)
    assembler.resolver.mainStore().warehouse.add(item: .apple, count: 5)
    return TradingPostView(viewModel: assembler.resolver.tradingPostViewModel())
}
