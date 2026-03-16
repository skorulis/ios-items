// Created by Alexander Skorulis on 14/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct EssenceView {
    let essence: Essence
    static let size: CGFloat = 20
}

// MARK: - Rendering

extension EssenceView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .fill(essence.color)
                .frame(width: Self.size, height: Self.size)
                .rotationEffect(.degrees(45))
            essence.icon
                .font(.system(size: 10))
                .foregroundStyle(essence == .light ? .black : .white)
        }
        .frame(width: Self.size, height: Self.size)
    }
}

// MARK: - Previews

#Preview {
    HStack {
        ForEach(Essence.allCases) { essence in
            EssenceView(essence: essence)
        }
    }

}
