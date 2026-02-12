//Created by Alexander Skorulis on 12/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemPicker {
    let predicate: (BaseItem) -> Bool
    let onSelect: (BaseItem) -> Void
    
    init(
        predicate: @escaping (BaseItem) -> Bool = { _ in true},
        onSelect: @escaping (BaseItem) -> Void
    ) {
        self.predicate = predicate
        self.onSelect = onSelect
    }
}

// MARK: - Rendering

extension ItemPicker: View {
    
    var body: some View {
        ScrollView {
            items
        }
    }
    
    private var items: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80)),
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(visibleItems) { item in
                Button(action: { onSelect(item) }) {
                    ItemGridCell(item: item, quantity: nil)
                }
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

