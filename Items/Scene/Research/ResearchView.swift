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
                    viewModel.selectedItem = $0
                    viewModel.showingPicker = false
                }
            )
        }
    }
    
    private var content: some View {
        VStack {
            Spacer()
            Button("Select Item") {
                viewModel.showingPicker = true
            }
            itemView
            Spacer()
            button
        }
    }
    
    @ViewBuilder
    private var itemView: some View {
        if let item = viewModel.selectedItem {
            VStack {
                Button(action: viewModel.itemDetails) {
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
            Text("Success chance: \(100 * viewModel.chance)%")
        }
    }
    
    private func progressBar(item: BaseItem) -> some View {
        SegmentedResearchBar(
            research: item.availableResearch,
            level: viewModel.currentLevel
        )
    }
    
    private var button: some View {
        Button("Research") {
            viewModel.research()
        }
        .buttonStyle(CapsuleButtonStyle())
        .disabled(!viewModel.canStart)
    }
    
    private var titleBar: some View {
        TitleBar(
            title: "Research",
        )
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.mainStore().warehouse.add(item: .apple)
    return ResearchView(viewModel: assembler.resolver.researchViewModel())
}

