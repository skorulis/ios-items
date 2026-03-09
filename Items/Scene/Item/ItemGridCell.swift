//Created by Alexander Skorulis on 12/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemGridCell {
    let item: BaseItem
    let quantity: Int?
    var showNewBadge: Bool = false
}

// MARK: - Rendering

extension ItemGridCell: View {
    
    var body: some View {
        ItemView(item: item, quantity: quantity, showNewBadge: showNewBadge)
    }
}

// MARK: - Previews

#Preview {
    VStack {
        ItemGridCell(item: .apple, quantity: nil)
        ItemGridCell(item: .apple, quantity: 10)
        ItemGridCell(item: .potionFlask, quantity: 10, showNewBadge: true)
    }
    .background(Color.black)
    
}

