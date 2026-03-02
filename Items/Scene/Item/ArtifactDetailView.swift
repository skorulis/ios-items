//Created by Alexander Skorulis on 15/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct ArtifactDetailView {
    @State var viewModel: ArtifactDetailViewModel
}

// MARK: - Rendering

extension ArtifactDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ArtifactView(artifact: viewModel.artifact)

                Text(viewModel.artifact.type.name)
                    .font(.title)

                Spacer()
            }

            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Quality:")
                        .font(.headline)
                    Text(viewModel.artifact.quality.name)
                        .foregroundStyle(viewModel.artifact.quality.color)
                        .bold()
                    Spacer()
                }

                Text(viewModel.artifact.bonusMessage)
            }

            HStack(spacing: 12) {
                if viewModel.isEquipped {
                    Button("Unequip", action: viewModel.unequip)
                        .buttonStyle(CapsuleButtonStyle())
                } else {
                    Button("Equip", action: viewModel.equip)
                        .buttonStyle(CapsuleButtonStyle())
                }
            }
        }
        .padding(16)
        .onAppear { viewModel.markArtifactViewed() }
    }
}

// MARK: - Previews

#Preview("Artifact Detail") {
    let assembler = ItemsAssembly.testing()
    ArtifactDetailView(
        viewModel: assembler.resolver.artifactDetailViewModel(artifact: .init(type: .frictionlessGear, quality: .good))
    )
}

