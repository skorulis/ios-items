//Created by Alexander Skorulis on 2/3/2026.

import SwiftUI

// MARK: - Memory footprint

struct AvatarStack {
    private let avatars: [AvatarView]
    private let size: AvatarView.Size

    init(
        avatars: [AvatarView],
        size: AvatarView.Size
    ) {
        self.avatars = avatars
        self.size = size
    }
}

// MARK: - Rendering

extension AvatarStack: View {
    var body: some View {
        HStack(spacing: -size.stackOverlap) {
            ForEach(avatars.indices, id: \.self) { index in
                avatars[index]
            }
        }
    }
}

extension AvatarView.Size {
    fileprivate var stackOverlap: CGFloat {
        return self.diameter / 2
    }
}

// MARK: - Previews

#Preview {
    VStack {
        AvatarStack(
            avatars: [
                AvatarView(text: "AB", image: nil, border: .orange, size: .small),
                AvatarView(text: "CD", image: nil, border: .blue, size: .small),
                AvatarView(text: "EF", image: nil, border: .green, size: .small),
            ],
            size: .small,
        )
        
        AvatarStack(
            avatars: [
                AvatarView(text: "AB", image: nil, border: .orange, size: .large),
                AvatarView(text: "CD", image: nil, border: .blue, size: .large),
            ],
            size: .large,
        )
    }
    
}
