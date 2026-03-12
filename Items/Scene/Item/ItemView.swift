//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemView {
    let item: BaseItem
    let quantity: Int?
    let showNewBadge: Bool
    let size: AvatarView.Size
    
    init(
        item: BaseItem,
        quantity: Int? = nil,
        showNewBadge: Bool = false,
        size: AvatarView.Size = .medium
    ) {
        self.item = item
        self.quantity = quantity
        self.showNewBadge = showNewBadge
        self.size = size
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
            size: size,
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

