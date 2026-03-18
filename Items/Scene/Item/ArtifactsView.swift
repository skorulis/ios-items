// Created by Alexander Skorulis on 11/2/2026.
//
// Split out artifacts UI from `WarehouseView`.

import Knit
import Models
import SwiftUI

@MainActor
struct ArtifactsView: View {
    @State var viewModel: ArtifactsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.model.maxArtifactSlots > 0 {
                equippedSection
            }
            ArtifactsListView(
                warehouse: viewModel.warehouse,
                onArtifactPressed: { viewModel.pressed(artifact: $0) },
                isNew: { viewModel.isNew(artifact: $0) }
            )
        }
    }

    private var equippedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Equipped")
                    .font(.appTitle)

                Button(action: viewModel.showArtifactBonusesInfo) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color.black)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            let maxSlots = viewModel.model.maxArtifactSlots
            let slots = viewModel.warehouse.equippedSlotsContents(upToSlotCount: maxSlots)

            ArtifactSlotView(slots: slots, size: .large) { index in
                viewModel.artifactSlotPresed(index: index)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Previews

#Preview("Artifacts (equipped)") {
    let assembler = ItemsAssembly.testing()
    let viewModel = assembler.resolver.warehouseViewModel()
    viewModel.page = .artifacts
    return WarehouseView(viewModel: viewModel)
}
