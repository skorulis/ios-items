//Created by Alexander Skorulis on 12/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemGridCell {
    let item: BaseItem
    let quantity: Int?
}

// MARK: - Rendering

extension ItemGridCell: View {
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ItemView(item: item)
            
            if let quantity {
                Text("\(quantity)")
                    .monospaced()
                    .bold()
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
                    .padding(2)
                    .background(Capsule())
                    .padding(2)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    VStack {
        ItemGridCell(item: .apple, quantity: nil)
        ItemGridCell(item: .apple, quantity: 10)
    }
    .background(Color.black)
    
}

