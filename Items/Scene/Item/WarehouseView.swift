// Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Knit
import Models
import SwiftUI

@MainActor
struct WarehouseView: View {
    @State var viewModel: WarehouseViewModel

    struct Model {
        var newItemsToShow: Set<Ingredient> = []
        var showArtifactsTab: Bool = false
        var showTradingPostButton: Bool = false
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
            case .equipment:
                EquipmentListView(
                    viewModel: viewModel.equipmentListViewModel,
                    contentOnly: true
                )
            }
        }
    }

    @ViewBuilder
    private var maybePicker: some View {
        if viewModel.model.showArtifactsTab || viewModel.hasEquipment {
            Picker("Page", selection: $viewModel.page) {
                Text("Ingredients")
                    .tag(WarehouseViewModel.Page.items)
                if viewModel.model.showArtifactsTab {
                    Text("Artifacts")
                        .tag(WarehouseViewModel.Page.artifacts)
                }
                if viewModel.hasEquipment {
                    Text("Equipment")
                        .tag(WarehouseViewModel.Page.equipment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
        }
    }

    private var artifacts: some View {
        ArtifactsView(viewModel: viewModel.artifactsViewModel)
    }

    private var items: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
        let grouped = Dictionary(grouping: Ingredient.allCases, by: { $0.quality })

        return LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(ItemQuality.allCases, id: \.self) { quality in
                if let itemsInQuality = grouped[quality], !itemsInQuality.isEmpty,
                   itemsInQuality.contains(where: { viewModel.warehouse.hasDiscovered($0) }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quality.name)
                            .font(.appSectionTitle)
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
    private func cell(item: Ingredient) -> some View {
        if viewModel.warehouse.hasDiscovered(item) {
            Button(
                action: {viewModel.pressed(item: item)},
                label: {
                    ItemGridCell(
                        item: item,
                        quantity: viewModel.warehouse.quantity(item),
                        showNewBadge: viewModel.isNew(item: item)
                    )
                }
            )
        } else {
            AvatarView.emptyState(size: .medium)
                .grayscale(0.9)
        }
    }

    private var titleBar: some View {
        TitleBar(
            title: "Warehouse",
            trailing: {
                HStack(spacing: 8) {
                    essenceBreakdownButton
                    if viewModel.model.showTradingPostButton {
                        tradingPostButton
                    }
                    if viewModel.hasEquipment {
                        equipmentButton
                    }
                    if viewModel.hasDiscoveredRecipes {
                        craftingButton
                    }
                    helpButton
                }
            }
        )
    }

    private var essenceBreakdownButton: some View {
        Button(
            action: { viewModel.showEssenceBreakdown() },
            label: {
                Image(systemName: "chart.pie")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.black)
            }
        )
    }

    private var tradingPostButton: some View {
        Button(action: viewModel.showTradingPost) {
            Image(systemName: "storefront")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.black)
        }
    }

    private var craftingButton: some View {
        Button(action: viewModel.showCrafting) {
            Image(systemName: "hammer")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.black)
        }
    }

    private var equipmentButton: some View {
        Button(action: viewModel.showEquipmentList) {
            Image(systemName: "backpack")
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
