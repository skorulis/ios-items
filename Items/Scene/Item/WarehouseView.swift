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
            }
        } else {
            Image(systemName: "questionmark.circle")
                .resizable()
                .frame(width: 60, height: 60)
        }
        
    }
    
    @ViewBuilder
    private func cell(item: BaseItem) -> some View {
        if viewModel.warehouse.hasDiscovered(item) {
            Button(action: {viewModel.pressed(item: item)}) {
                ItemGridCell(
                    item: item,
                    quantity: viewModel.warehouse.quantity(item)
                )
            }
        } else {
            AvatarView(
                text: "",
                image: Image(systemName: "questionmark"),
                border: .black
            )
            .grayscale(0.9)
        }
    }
    
    private var titleBar: some View {
        TitleBar(
            title: "Warehouse",
            backAction: { viewModel.coordinator?.retreat() }
        )
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.mainStore().warehouse.add(item: .apple)
    return WarehouseView(viewModel: assembler.resolver.warehouseViewModel())
}
