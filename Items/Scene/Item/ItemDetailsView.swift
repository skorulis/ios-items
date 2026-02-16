//Created by Alexander Skorulis on 14/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemDetailsView {
    @State var viewModel: ItemDetailsViewModel
}

// MARK: - Rendering

extension ItemDetailsView: View {
    
    var item: BaseItem { viewModel.item }
    var level: Int { viewModel.lab.currentLevel(item: viewModel.item) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                ItemView(item: item)
                Text(item.name)
                    .font(.title)
                Spacer()
            }
            Text("Quality \(item.quality.name)")
            essences
            if let lore = combinedLore {
                Text(lore)
            }
            researchProgress
            Text("Double chance: \(viewModel.doubleChanceString)")
        }
        .padding(16)
        .background(CardBackground())
        .padding(16)
    }
    
    private var researchProgress: some View {
        Text("Research level: \(level)")
    }
    
    private var essences: some View {
        HStack {
            Text("Essence")
            ForEach(Array(0..<item.essences.count), id: \.self) { index in
                if level > index {
                    EssenceView(essence: item.essences[index])
                } else {
                    Text("?")
                }
            }
        }
        
    }
    
    private var combinedLore: String? {
        // TODO: Only show discovered lore
        return item.lore.joined(separator: "\n")
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    ItemDetailsView(
        viewModel: assembler.resolver.itemDetailsViewModel(item: BaseItem.apple),
    )
}
