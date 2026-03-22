import Foundation
import Knit
import Models
import SwiftUI

@MainActor
struct GolemsView: View {
    @State var viewModel: GolemsViewModel

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var titleBar: some View {
        TitleBar(title: "Golems", backAction: nil)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Mode", selection: $viewModel.segment) {
                ForEach(GolemsViewModel.Segment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            switch viewModel.segment {
            case .construction:
                constructionList
            case .missions:
                missionsList
            }
        }
    }

    private var missionsList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(Array(viewModel.missionSlotIndices), id: \.self) { index in
                GolemMissionSlotView(slotIndex: index, viewModel: viewModel)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var constructionList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.allGolemTypes, id: \.self) { golemType in
                GolemConstructionRow(
                    golemType: golemType,
                    ownedCount: viewModel.owned(golemType),
                    itemQuantity: { viewModel.warehouse.quantity($0) },
                    canPurchase: viewModel.canPurchase(golemType),
                    onPurchase: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            viewModel.purchase(golemType)
                        }
                    },
                    onInfo: { viewModel.showGolemInfo(golemType) }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemsView(viewModel: assembler.resolver.golemsViewModel())
}
