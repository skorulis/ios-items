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
            content: { items }
        )
    }
    
    private var items: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80)),
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(BaseItem.allCases) { item in
                cell(item: item)
            }
        }
        .padding(16)
    }
    
    private func cell(item: BaseItem) -> some View {
        ItemGridCell(
            item: item,
            quantity: viewModel.warehouse.quantity(item)
        )
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
    WarehouseView(viewModel: assembler.resolver.warehouseViewModel())
}
