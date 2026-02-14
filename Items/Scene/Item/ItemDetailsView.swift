//Created by Alexander Skorulis on 14/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ItemDetailsView {
    let item: BaseItem
    let research: Research
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
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
        )
        .padding(16)
    }
    
    private var researchProgress: some View {
        SegmentedProgressBar(
            totalSteps: item.availableResearch.level,
            currentStep: research.level,
        )
    }
    
    private var essences: some View {
        HStack {
            Text("Essence")
            ForEach(item.essences) { essence in
                if research.essences.contains(essence) {
                    EssenceView(essence: essence)
                } else {
                    Text("?")
                }
            }
        }
        
    }
    
    private var combinedLore: String? {
        let count = min(research.lore, item.lore.count)
        if count == 0 {
            return nil
        }
        return item.lore.prefix(count).joined(separator: "\n")
    }
}

// MARK: - Previews

#Preview {
    ItemDetailsView(
        item: .apple,
        research: BaseItem.apple.availableResearch
    )
}

