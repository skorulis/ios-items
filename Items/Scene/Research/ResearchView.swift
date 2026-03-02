//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ResearchView {
    @State var viewModel: ResearchViewModel
}

// MARK: - Rendering

extension ResearchView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            titleBar
            content
        }
        .sheet(isPresented: $viewModel.showingPicker) {
            ItemPicker(
                predicate: { viewModel.warehouse.quantity($0) > 0 },
                onSelect: {
                    viewModel.selectAndBeginResearch(item: $0)
                    viewModel.showingPicker = false
                }
            )
        }
        .onAppear { viewModel.startTimer() }
        .onDisappear { viewModel.stopTimer() }
    }
    
    private var content: some View {
        VStack {
            Spacer()
            Button("Select Item") {
                viewModel.showingPicker = true
            }
            itemView
            Spacer()
        }
    }
    
    @ViewBuilder
    private var itemView: some View {
        if let item = viewModel.lab.currentResearch?.item {
            VStack {
                Button(action: { viewModel.viewItemDetails() }) {
                    ItemGridCell(item: item, quantity: viewModel.warehouse.quantity(item))
                }
                textBlock(item: item)
                progressBar(item: item)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func textBlock(item: BaseItem) -> some View {
        VStack {
            Text("Level: \(viewModel.currentLevel)")
        }
    }
    
    private func progressBar(item: BaseItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SegmentedResearchBar(
                research: item.availableResearch,
                level: viewModel.currentLevel
            )
            ResearchBarView(
                totalSeconds: viewModel.totalSeconds,
                completedSeconds: viewModel.completedSeconds
            )
            ResearchRushButton(
                item: item,
                cost: viewModel.rushCost,
                isEnabled: viewModel.canRush,
                action: { viewModel.rushCurrentResearch() }
            )
        }
    }
    
    private var titleBar: some View {
        TitleBar(
            title: "Research",
            trailing: { helpButton }
        )
    }

    private var helpButton: some View {
        Button(action: { viewModel.showHelp() }) {
            Image(systemName: "questionmark.app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.black)
        }
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.mainStore().warehouse.add(item: .apple)
    return ResearchView(viewModel: assembler.resolver.researchViewModel())
}
