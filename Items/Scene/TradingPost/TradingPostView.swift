import ASKCoordinator
import Knit
import Models
import SwiftUI
import Foundation

@MainActor
struct TradingPostView: View {
    @State var viewModel: TradingPostViewModel

    @Environment(\.dismissCircularReveal) private var dismissCircularReveal

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
                Text("Refresh costs \(viewModel.currentRefreshCostSigil) sigil\(viewModel.currentRefreshCostSigil == 1 ? "" : "s")")
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
            ForEach(viewModel.trades) { trade in
                tradeCard(for: trade)
            }
        }
    }

    private func tradeCard(for trade: TradingPostTrade) -> some View {
        let remaining = viewModel.remainingExecutions(for: trade)
        let missing = viewModel.missingFromItemCount(for: trade)
        let rarityColor = trade.fromItem.quality.color

        return VStack(alignment: .leading, spacing: 12) {
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

            HStack {
                Text("Uses left")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Text("\(remaining)/\(TradingPostTrade.maxExecutionsPerTrade)")
                    .font(.appMonospaceBadge)
            }

            tradeButton(trade: trade)
        }
        .padding(14)
        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(rarityColor.opacity(0.25), lineWidth: 1)
        )
    }
    
    private func tradeButton(trade: TradingPostTrade) -> some View {
        let remaining = viewModel.remainingExecutions(for: trade)
        let missing = viewModel.missingFromItemCount(for: trade)
        return Button(
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

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.mainStore().warehouse.add(item: .rock, count: 15)
    assembler.resolver.mainStore().warehouse.add(item: .apple, count: 5)
    return TradingPostView(viewModel: assembler.resolver.tradingPostViewModel())
}
