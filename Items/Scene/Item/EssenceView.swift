//Created by Alexander Skorulis on 14/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct EssenceView {
    let essence: Essence
}

// MARK: - Rendering

extension EssenceView: View {
    
    var body: some View {
        Circle()
            .fill(essence.color)
            .frame(width: 24, height: 24)
    }
}

// MARK: - Previews

#Preview {
    HStack {
        EssenceView(essence: .dark)
        EssenceView(essence: .light)
    }
    
}

