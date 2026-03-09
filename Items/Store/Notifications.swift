// Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models

/// Owns all notification state for what badges, "new" indicators, and alerts should be shown.
/// Values are written by MainStore (from warehouse discoveries, achievements, research) and persisted.
struct Notifications: Codable, Equatable {
    /// New warehouse items to show as "new" in the UI.
    var newItems: Set<BaseItem> = []
    /// New warehouse artifacts to show as "new" in the UI.
    var newArtifacts: Set<Artifact> = []
    /// New achievements to show as "new" in the UI.
    var newAchievements: Set<Achievement> = []
    /// Whether a new research level has been reached and not yet viewed.
    var newResearchLevels: Int = 0

    /// Number of new item/artifact discoveries in the warehouse not yet viewed.
    var warehouseNewCount: Int {
        newItems.count + newArtifacts.count
    }

    /// Number of newly unlocked achievements not yet viewed.
    var achievementsNewCount: Int {
        newAchievements.count
    }

    // MARK: - Mutations (used by MainStore)

    mutating func recordNewItemDiscovery(_ item: BaseItem) {
        newItems.insert(item)
    }

    mutating func recordNewArtifactDiscovery(_ artifact: Artifact) {
        newArtifacts.insert(artifact)
    }

    mutating func recordNewAchievements(_ achievements: Set<Achievement>) {
        newAchievements.formUnion(achievements)
    }

    mutating func recordNewResearchLevel() {
        newResearchLevels += 1
    }

    mutating func clearNewAchievements() {
        newAchievements.removeAll()
    }

    mutating func clearNewResearchLevel() {
        newResearchLevels = 0
    }

    mutating func markItemViewed(_ item: BaseItem) {
        newItems.remove(item)
    }

    mutating func markArtifactViewed(_ artifact: Artifact) {
        newArtifacts.remove(artifact)
    }
}
