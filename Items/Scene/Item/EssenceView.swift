// Created by Alexander Skorulis on 14/2/2026.

import Foundation
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct EssenceView {
    let essence: Essence
}

// MARK: - Rendering

extension EssenceView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .fill(essence.color)
                .frame(width: 16, height: 16)
                .rotationEffect(.degrees(45))
            essence.icon
                .font(.system(size: 8))
                .foregroundStyle(essence == .light ? .black : .white)
        }
        .frame(width: 20, height: 20)
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
