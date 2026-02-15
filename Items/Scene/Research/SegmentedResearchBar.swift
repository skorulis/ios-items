//Created by Alexander Skorulis on 15/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct SegmentedResearchBar {
    let research: Research
    let level: Int
}

// MARK: - Rendering

extension SegmentedResearchBar: View {
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<research.sections.count, id: \.self) { index in
                bar(index: index, section: research.sections[index])
            }
        }
    }
    
    private func bar(index: Int, section: ResearchSection) -> some View {
        ZStack {
            Capsule()
                .fill(fillColor(index: index, section: section))
                
            icon(index: index, section: section)
                .resizable()
                .foregroundStyle(iconColor(index: index, section: section))
                .frame(width: 16, height: 16)
        }
        .frame(height: 24)
    }
    
    private func fillColor(index: Int, section: ResearchSection) -> Color {
        if index >= level {
            return Color.gray
        } else {
            return Color.blue
        }
    }
    
    private func iconColor(index: Int, section: ResearchSection) -> Color {
        if index >= level {
            return Color.white
        } else {
            return section.iconColor
        }
    }
    
    private func icon(index: Int, section: ResearchSection) -> Image {
        if section.isInfinity {
            return Image(systemName: "infinity.circle.fill")
        }
        if index >= level {
            return Image(systemName: "questionmark.circle.dashed")
        }
        switch section {
        case .essence:
            return Image(systemName: "circle.fill")
        case .lore:
            return Image(systemName: "book.pages")
        case .infinity:
            return Image(systemName: "infinity.circle.fill")
        }
        
    }
}

// MARK: - Previews

#Preview {
    VStack {
        SegmentedResearchBar(
            research: BaseItem.apple.availableResearch, level: 0
        )
        
        SegmentedResearchBar(
            research: BaseItem.apple.availableResearch, level: 2
        )
    }
    .padding(16)
    
}

