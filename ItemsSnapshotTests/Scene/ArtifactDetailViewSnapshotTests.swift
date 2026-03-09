// Created by Cursor on 4/3/2026.

@testable import Items
import Knit
import Models
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct ArtifactDetailViewSnapshotTests {

    let assembler = ItemsAssembly.testing()

    @Test
    func artifactDetail_with_description() {
        let artifact = ArtifactInstance(type: .frictionlessGear, quality: .good)
        let viewModel = assembler.resolver.artifactDetailViewModel(artifact: artifact)
        let view = ArtifactDetailView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func artifactDetail_different_artifact() {
        let artifact = ArtifactInstance(type: .luckyCoin, quality: .rare)
        let viewModel = assembler.resolver.artifactDetailViewModel(artifact: artifact)
        let view = ArtifactDetailView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
