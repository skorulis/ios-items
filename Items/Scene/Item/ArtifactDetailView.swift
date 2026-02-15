//Created by Alexander Skorulis on 15/2/2026.

import Foundation
import SwiftUI
// MARK: - Memory footprint

@MainActor struct ArtifactDetailView {
    let artifact: ArtifactInstance
}

// MARK: - Rendering

extension ArtifactDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ArtifactView(artifact: artifact)
                
                Text(artifact.type.name)
                    .font(.title)
                
                Spacer()
                
            }

            // Details
            VStack(spacing: 8) {
                HStack {
                    Text("Quality:")
                        .font(.headline)
                    Text(artifact.quality.name)
                        .foregroundStyle(artifact.quality.color)
                        .bold()
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(CardBackground())
        .padding(16)
    }
}

// MARK: - Previews

#Preview("Artifact Detail") {
    ArtifactDetailView(
        artifact: .init(type: .frictionlessGear, quality: .good)
    )
}

