// Created by Alexander Skorulis on 11/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ArtifactView {
    let artifact: ArtifactInstance
}

// MARK: - Rendering

extension ArtifactView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(ColorHash.color(for: artifact.type.acronym))

            Circle()
                .stroke(artifact.quality.color, lineWidth: 2)

            Text(artifact.type.acronym)
                .font(.title)
                .bold()
                .foregroundStyle(Color.white)
        }
        .frame(width: 60, height: 60)
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
