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
        ZStack {
            Circle()
                .fill(ColorHash.color(for: item.acronym))
            
            Circle()
                .stroke(item.quality.color, lineWidth: 2)
            
            Text(item.acronym)
                .font(.title)
                .bold()
                .foregroundStyle(Color.white)
        }
        .frame(width: 60, height: 60)
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

