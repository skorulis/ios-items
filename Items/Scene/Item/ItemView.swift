//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemView {
    let item: BaseItem
}

// MARK: - Rendering

extension ItemView: View {
    
    var body: some View {
        AvatarView(initials: item.acronym, border: item.quality.color)
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

