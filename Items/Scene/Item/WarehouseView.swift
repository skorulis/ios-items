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
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(BaseItem.allCases) { item in
                cell(item: item)
            }
        }
        .padding(16)
    }
    
    private func cell(item: BaseItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(describing: item))
                .font(.headline)
            HStack {
                Text("Quantity:")
                    .foregroundStyle(.secondary)
                Text("\(viewModel.warehouse.quantity(item))")
                    .monospaced()
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
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
