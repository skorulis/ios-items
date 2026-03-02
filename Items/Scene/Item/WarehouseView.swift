//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import SwiftUI
import Knit

@MainActor
struct WarehouseView: View {
    @State var viewModel: WarehouseViewModel
    
    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Page", selection: $viewModel.page) {
                Text("Items")
                    .tag(WarehouseViewModel.Page.items)
                Text("Artifacts")
                    .tag(WarehouseViewModel.Page.artifacts)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            switch viewModel.page {
            case .items:
                items
            case .artifacts:
                artifacts
            }
        }
    }
    
    private var artifacts: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80)),
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Artifact.allCases) { artifact in
                artifactCell(artifact: artifact)
            }
        }
        .padding(16)
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
    private func artifactCell(artifact: Artifact) -> some View {
        if let instance = viewModel.warehouse.artifactInstance(artifact) {
            Button(action: { viewModel.pressed(artifact: instance) }) {
                ArtifactView(artifact: instance)
                    .overlay(alignment: .topTrailing) {
                        if viewModel.warehouse.isNew(artifact: artifact) {
                            Circle()
                                .fill(.red)
                                .frame(width: 10, height: 10)
                                .padding(4)
                        }
                    }
            }
        } else {
            AvatarView.emptyState(size: .medium)
                .grayscale(0.9)
        }
    }
    
    @ViewBuilder
    private func cell(item: BaseItem) -> some View {
        if viewModel.warehouse.hasDiscovered(item) {
            Button(action: {viewModel.pressed(item: item)}) {
                ItemGridCell(
                    item: item,
                    quantity: viewModel.warehouse.quantity(item),
                    showNewBadge: viewModel.warehouse.isNew(item: item)
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
            backAction: { viewModel.coordinator?.retreat() },
            trailing: { helpButton }
        )
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
