// Created by Alexander Skorulis on 11/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ArtifactView {
    let artifact: ArtifactInstance
    let size: AvatarView.Size
    
    init(artifact: ArtifactInstance, size: AvatarView.Size = .medium) {
        self.artifact = artifact
        self.size = size
    }
}

// MARK: - Rendering

extension ArtifactView: View {
    var body: some View {
        AvatarView(
            text: artifact.type.name,
            image: nil,
            border: artifact.quality.color,
            size: size
        )
    }
}

// MARK: - Previews

#Preview("Artifacts") {
    HStack(spacing: 8) {
        ArtifactView(
            artifact: .init(type: .frictionlessGear, quality: .junk)
        )
        
        ArtifactView(
            artifact: .init(type: .frictionlessGear, quality: .exceptional)
        )
    }
}
