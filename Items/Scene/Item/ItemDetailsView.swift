//Created by Alexander Skorulis on 14/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemDetailsView {
    let item: BaseItem
    let level: Int
}

// MARK: - Rendering

extension ItemDetailsView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                ItemView(item: item)
                Text(item.name)
                    .font(.title)
                Spacer()
            }
            Text("Quality \(item.quality.name)")
            essences
            if let lore = combinedLore {
                Text(lore)
            }
            researchProgress
        }
        .padding(16)
        .background(CardBackground())
        .padding(16)
    }
    
    private var researchProgress: some View {
        Text("Research level: \(level)")
    }
    
    private var essences: some View {
        HStack {
            Text("Essence")
            ForEach(Array(0..<item.essences.count), id: \.self) { index in
                if level > index {
                    EssenceView(essence: item.essences[index])
                } else {
                    Text("?")
                }
            }
        }
        
    }
    
    private var combinedLore: String? {
        // TODO: Only show discovered lore
        return item.lore.joined(separator: "\n")
    }
}

// MARK: - Previews

#Preview {
    ItemDetailsView(
        item: .apple,
        level: 2,
    )
}

