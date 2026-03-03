//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemView {
    let item: BaseItem
    let quantity: Int?
    var showNewBadge: Bool = false
    
    init(item: BaseItem, quantity: Int? = nil, showNewBadge: Bool = false) {
        self.item = item
        self.quantity = quantity
        self.showNewBadge = showNewBadge
    }
}

// MARK: - Rendering

extension ItemView: View {
    
    var body: some View {
        AvatarView(
            text: item.name,
            image: item.image,
            border: item.quality.color,
            badge: badgeText,
            showNewBadge: showNewBadge,
        )
    }
    
    private var badgeText: String? {
        return quantity.map(String.init)
    }
}

// MARK: - Previews

#Preview {
    HStack(spacing: 8) {
        ItemView(item: .gear)
        ItemView(item: .silverFlorin)
        ItemView(item: .goldFlorin)
    }
}

