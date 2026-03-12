//Created by Alexander Skorulis on 12/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemPicker {
    let title: String
    let predicate: (BaseItem) -> Bool
    let onSelect: (BaseItem) -> Void

    init(
        title: String = "Choose item",
        predicate: @escaping (BaseItem) -> Bool = { _ in true },
        onSelect: @escaping (BaseItem) -> Void
    ) {
        self.title = title
        self.predicate = predicate
        self.onSelect = onSelect
    }
}

// MARK: - Rendering

extension ItemPicker: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView {
                items
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var items: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80), spacing: 12),
        ]
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(visibleItems) { item in
                Button(action: { onSelect(item) }) {
                    ItemGridCell(item: item, quantity: nil)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var visibleItems: [BaseItem] {
        BaseItem.allCases.filter(predicate)
    }
}

// MARK: - Previews

#Preview {
    ItemPicker(onSelect: { _ in })
}

