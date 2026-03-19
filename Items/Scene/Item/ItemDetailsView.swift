// Created by Alexander Skorulis on 14/2/2026.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemDetailsView {
    @State var viewModel: ItemDetailsViewModel
}

// MARK: - Rendering

extension ItemDetailsView: View {

    var item: BaseItem { viewModel.model.item }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ItemView(item: item)
                    titleBar
                    Spacer()
                }
                HStack(spacing: 4) {
                    Text("Quality:")
                    Text(item.quality.name)
                        .bold()
                        .foregroundStyle(item.quality.color)
                }
                researchProgress
                Text("Duplicate item chance: \(viewModel.model.details.doubleChance)")
                artifactSection

                if let lore = combinedLore {
                    Divider()
                    Text(lore)
                }
            }

            if viewModel.canResearch {
                Button(viewModel.isResearchingThisItem ? "Stop Research" : "Research") {
                    viewModel.toggleResearch()
                }
                .buttonStyle(CapsuleButtonStyle())
            }
        }
        .padding(16)
        .onAppear { viewModel.markItemViewed() }
    }

    private var titleBar: some View {
        VStack(alignment: .leading, spacing: 0) {
            essences
            Text(item.name)
                .font(.appTitle)
        }
    }

    @ViewBuilder
    private var artifactSection: some View {
        if let artifact = viewModel.model.unlockedArtifact {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Artifact:")
                    if let instance = viewModel.model.warehouse.artifactInstance(artifact) {
                        Button {
                            viewModel.pressed(artifactInstance: instance)
                        } label: {
                            ArtifactView(artifact: instance, size: .small)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: "questionmark.circle.dashed")
                    }
                    if let chanceText = viewModel.nextLevelArtifactChanceString {
                        Text(chanceText)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var researchProgress: some View {
        if let researchLevel = viewModel.model.details.researchLevel {
            Text("Research level: \(researchLevel)")
        }
    }

    private var essences: some View {
        HStack {
            ForEach(Array(viewModel.model.details.essences.enumerated()), id: \.offset) { _, essence in
                if let essence {
                    EssenceView(essence: essence)
                } else {
                    Image(systemName: "questionmark.diamond")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: EssenceView.size, height: EssenceView.size)
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
        let item: BaseItem
        var lab: Laboratory
        var warehouse: Warehouse
        var details: ItemDetails

        var unlockedArtifact: Artifact? {
            item.associatedArtifact
        }
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    ItemDetailsView(
        viewModel: assembler.resolver.itemDetailsViewModel(item: BaseItem.gear),
    )
}
