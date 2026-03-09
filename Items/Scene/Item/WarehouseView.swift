//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Knit
import Models
import SwiftUI

@MainActor
struct WarehouseView: View {
    @State var viewModel: WarehouseViewModel

    struct Model {
        var newItemsToShow: Set<BaseItem> = []
        var newArtifactsToShow: Set<Artifact> = []
        var showArtifactsTab: Bool = false
        var maxArtifactSlots: Int = 0
    }

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            maybePicker
            switch viewModel.page {
            case .items:
                items
            case .artifacts:
                artifacts
            }
        }
    }
    
    @ViewBuilder
    private var maybePicker: some View {
        if viewModel.model.showArtifactsTab {
            Picker("Page", selection: $viewModel.page) {
                Text("Items")
                    .tag(WarehouseViewModel.Page.items)
                Text("Artifacts")
                    .tag(WarehouseViewModel.Page.artifacts)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
        }
    }
    
    private var artifacts: some View {
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
            Text("Equipped")
                .font(.headline)
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
    
    private var items: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80)),
        ]
        let grouped = Dictionary(grouping: BaseItem.allCases, by: { $0.quality })

        return LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(ItemQuality.allCases, id: \.self) { quality in
                if let itemsInQuality = grouped[quality], !itemsInQuality.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quality.name)
                            .font(.headline)
                            .foregroundStyle(quality.color)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(itemsInQuality) { item in
                                cell(item: item)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func cell(item: BaseItem) -> some View {
        if viewModel.warehouse.hasDiscovered(item) {
            Button(action: {viewModel.pressed(item: item)}) {
                ItemGridCell(
                    item: item,
                    quantity: viewModel.warehouse.quantity(item),
                    showNewBadge: viewModel.isNew(item: item)
                )
            }
        } else {
            AvatarView.emptyState(size: .medium)
                .grayscale(0.9)
        }
    }
    
    private var titleBar: some View {
        TitleBar(
            title: "Warehouse",
            trailing: { HStack(spacing: 8) { essenceBreakdownButton; helpButton } }
        )
    }

    private var essenceBreakdownButton: some View {
        Button(action: { viewModel.showEssenceBreakdown() }) {
            Image(systemName: "chart.pie")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.black)
        }
    }

    private var helpButton: some View {
        Button(action: viewModel.showInfo) {
            Image(systemName: "questionmark.app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.black)
        }
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.mainStore().warehouse.add(item: .apple)
    return WarehouseView(viewModel: assembler.resolver.warehouseViewModel())
}
