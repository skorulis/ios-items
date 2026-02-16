//Created by Alexander Skorulis on 16/2/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct AvatarView {
    let initials: String
    let border: Color
}

// MARK: - Rendering

extension AvatarView: View {
    
    var body: some View {
        ZStack {
            Circle()
                .fill(ColorHash.color(for: initials))
            
            Circle()
                .stroke(border, lineWidth: 2)
            
            Text(initials)
                .font(.title)
                .bold()
                .foregroundStyle(Color.white)
        }
        .frame(width: 60, height: 60)
    }
}

// MARK: - Previews

#Preview {
    AvatarView(
        initials: "AB",
        border: .orange,
    )
}

