//Created by Alexander Skorulis on 15/2/2026.

import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ArtifactDetailViewModel {

    let artifact: ArtifactInstance

    private let mainStore: MainStore
    private(set) var equippedArtifacts: [Artifact] = []
    private var cancellables = Set<AnyCancellable>()

    @Resolvable<BaseResolver>
    init(@Argument artifact: ArtifactInstance, mainStore: MainStore) {
        self.artifact = artifact
        self.mainStore = mainStore
        equippedArtifacts = mainStore.warehouse.equippedArtifacts
        mainStore.$warehouse
            .map(\.equippedArtifacts)
            .sink { [weak self] in self?.equippedArtifacts = $0 }
            .store(in: &cancellables)
    }
}

// MARK: - Logic

extension ArtifactDetailViewModel {

    var isEquipped: Bool {
        equippedArtifacts.contains(artifact.type)
    }

    func markArtifactViewed() {
        mainStore.markArtifactViewed(artifact.type)
    }

    func equip() {
        mainStore.warehouse.equip(artifact.type)
    }

    func unequip() {
        mainStore.warehouse.unequip(artifact.type)
    }
}
