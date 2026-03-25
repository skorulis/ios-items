// Created by Alexander Skorulis on 15/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct SegmentedResearchBar {
    let research: Research
    let level: Int
    let onTapLevel: (Int) -> Void
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
        Button(
            action: { onTapLevel(index) },
            label: {
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
        )
        .buttonStyle(.plain)
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
        let unlocked = level > index
        switch section {
        case .essence:
            return unlocked
                ? Image(systemName: "diamond.fill")
                : Image(systemName: "questionmark.diamond")
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
            research: Ingredient.apple.availableResearch,
            level: 0,
            onTapLevel: { _ in }
        )

        SegmentedResearchBar(
            research: Ingredient.apple.availableResearch,
            level: 2,
            onTapLevel: { _ in }
        )
    }
    .padding(16)

}
