//Created by Alexander Skorulis on 16/2/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct AvatarView {
    let initials: String
    let border: Color
    
    let badge: String?
    
    init(
        initials: String,
        border: Color,
        badge: String? = nil
    ) {
        self.initials = initials
        self.border = border
        self.badge = badge
    }
}

// MARK: - Rendering

extension AvatarView: View {
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            mainCircle
            maybeBadge
        }
    }
    
    private var mainCircle: some View {
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
    
    @ViewBuilder
    private var maybeBadge: some View {
        if let badge {
            Text(badge)
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

// MARK: - Previews

#Preview {
    AvatarView(
        initials: "AB",
        border: .orange,
    )
}

