// Created by Alexander Skorulis on 12/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemPicker {
    let title: String
    let predicate: (Ingredient) -> Bool
    let quantity: (Ingredient) -> Int?
    let onSelect: (Ingredient) -> Void

    init(
        title: String = "Choose item",
        predicate: @escaping (Ingredient) -> Bool = { _ in true },
        quantity: @escaping (Ingredient) -> Int? = { _ in nil },
        onSelect: @escaping (Ingredient) -> Void
    ) {
        self.title = title
        self.predicate = predicate
        self.quantity = quantity
        self.onSelect = onSelect
    }
}

// MARK: - Rendering

extension ItemPicker: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.appTitle)
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
            GridItem(.adaptive(minimum: 80), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(visibleItems) { item in
                Button(
                    action: { onSelect(item) },
                    label: {
                        ItemGridCell(item: item, quantity: quantity(item))
                    }
                )
                .buttonStyle(.plain)
            }
        }
    }

    private var visibleItems: [Ingredient] {
        Ingredient.allCases.filter(predicate)
    }
}

// MARK: - Previews

#Preview {
    ItemPicker(onSelect: { _ in })
}
