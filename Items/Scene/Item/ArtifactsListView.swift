//Created by Alexander Skorulis on 11/2/2026.

import SwiftUI
import Knit

/// Reusable list of artifacts grouped by rarity (quality).
/// Can be used in Warehouse, Encyclopedia, or other screens.
@MainActor
struct ArtifactsListView: View {
    let warehouse: Warehouse
    var onArtifactPressed: ((ArtifactInstance) -> Void)? = nil
    var isNew: ((Artifact) -> Bool)? = nil
    
    // Artifacts to show in the list
    var artifacts: [Artifact] = Artifact.allCases

    private let columns = [
        GridItem(.adaptive(minimum: 80)),
    ]

    var body: some View {
        let grouped = Dictionary(grouping: artifacts) { artifact in
            warehouse.artifactInstance(artifact)?.quality
        }
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(ItemQuality.allCases, id: \.self) { quality in
                if let artifactsInQuality = grouped[quality as ItemQuality?], !artifactsInQuality.isEmpty {
                    qualitySection(quality: quality, artifacts: artifactsInQuality)
                }
            }
            if let undiscovered = grouped[nil], !undiscovered.isEmpty {
                undiscoveredSection(artifacts: undiscovered)
            }
        }
        .padding(.vertical, 16)
    }

    private func qualitySection(quality: ItemQuality, artifacts: [Artifact]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quality.name)
                .font(.headline)
                .foregroundStyle(quality.color)
                .padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(artifacts) { artifact in
                    artifactCell(artifact: artifact)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func undiscoveredSection(artifacts: [Artifact]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Not discovered")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(artifacts) { artifact in
                    artifactCell(artifact: artifact)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func artifactCell(artifact: Artifact) -> some View {
        if let instance = warehouse.artifactInstance(artifact) {
            let content = ArtifactView(artifact: instance)
                .overlay(alignment: .topTrailing) {
                    if isNew?(artifact) == true {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .padding(4)
                    }
                }
            if let onPressed = onArtifactPressed {
                Button(action: { onPressed(instance) }) {
                    content
                }
            } else {
                content
            }
        } else {
            AvatarView.emptyState(size: .medium)
                .grayscale(0.9)
        }
    }
}

#Preview("Read-only") {
    let warehouse = Warehouse()
    return ScrollView {
        ArtifactsListView(warehouse: warehouse)
    }
}

#Preview("With artifacts") {
    var warehouse = Warehouse()
    warehouse.add(artifact: ArtifactInstance(type: .frictionlessGear, quality: .good))
    warehouse.add(artifact: ArtifactInstance(type: .luckyCoin, quality: .common))
    return ScrollView {
        ArtifactsListView(warehouse: warehouse)
    }
}
