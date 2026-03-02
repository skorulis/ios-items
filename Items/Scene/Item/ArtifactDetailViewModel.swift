//Created by Alexander Skorulis on 15/2/2026.

import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ArtifactDetailViewModel {

    let artifact: ArtifactInstance

    private let mainStore: MainStore

    @Resolvable<BaseResolver>
    init(@Argument artifact: ArtifactInstance, mainStore: MainStore) {
        self.artifact = artifact
        self.mainStore = mainStore
    }
}

// MARK: - Logic

extension ArtifactDetailViewModel {

    func markArtifactViewed() {
        mainStore.markArtifactViewed(artifact.type)
    }
}
