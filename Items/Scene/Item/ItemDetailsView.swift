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
    var level: Int { viewModel.model.lab.currentLevel(item: viewModel.item) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                ItemView(item: item)
                titleBar
                Spacer()
            }
            Text("Quality \(item.quality.name)")
            researchProgress
            Text("Double chance: \(viewModel.doubleChanceString)")
            artifactSection
            
            if let lore = combinedLore {
                Text(lore)
            }
        }
        .padding(16)
    }
    
    private var titleBar: some View {
        VStack(alignment: .leading, spacing: 0) {
            essences
            Text(item.name)
                .font(.title)
        }
    }
    
    @ViewBuilder
    private var artifactSection: some View {
        if let artifact = viewModel.item.associatedArtifact {
            HStack {
                Text("Artifact:")
                if let instance = viewModel.model.warehouse.artifactInstance(artifact) {
                    ArtifactView(artifact: instance, size: .small)
                } else {
                    Image(systemName: "questionmark.circle.dashed")
                }
            }
        }
    }
    
    private var researchProgress: some View {
        Text("Research level: \(level)")
    }
    
    private var essences: some View {
        HStack {
            ForEach(Array(0..<item.essences.count), id: \.self) { index in
                if level > index {
                    EssenceView(essence: item.essences[index])
                } else {
                    Image(systemName: "questionmark.circle.dashed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
            }
        }
        
    }
    
    private var combinedLore: String? {
        // TODO: Only show discovered lore
        return item.lore.joined(separator: "\n")
    }
}

extension ItemDetailsView {
    struct Model {
        var lab: Laboratory
        var warehouse: Warehouse
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    ItemDetailsView(
        viewModel: assembler.resolver.itemDetailsViewModel(item: BaseItem.gear),
    )
}
