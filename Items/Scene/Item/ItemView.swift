//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemView {
    let item: BaseItem
    let quantity: Int?
    
    init(item: BaseItem, quantity: Int? = nil) {
        self.item = item
        self.quantity = quantity
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
        )
    }
    
    private var badgeText: String? {
        return quantity.map(String.init)
    }
}

// MARK: - Previews

#Preview {
    HStack(spacing: 8) {
        ItemView(item: .cactus)
        ItemView(item: .gear)
        ItemView(item: .compass)
        ItemView(item: .silverFlorin)
    }
}

