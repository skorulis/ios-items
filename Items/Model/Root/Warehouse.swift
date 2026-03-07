//Created by Alexander Skorulis on 10/2/2026.

import Foundation

struct Warehouse: Codable {
    // Current item storage
    private var current: [BaseItem: Int] = [:]
    
    // Discovered artifacts
    private var artifacts: [Artifact: ItemQuality] = [:]
    
    // Total items that have been found
    private var total: [BaseItem: Int] = [:]

    // Equipped artifacts
    var equippedSlots: [Int: Artifact] = [:]

    func isNewDiscovery(item: BaseItem) -> Bool {
        return (total[item] ?? 0) == 0
    }
    
    func isNewDiscovery(artifact: ArtifactInstance) -> Bool {
        if let existing = artifacts[artifact.type] {
            return artifact.quality > existing
        } else {
            return true
        }
    }
    
    mutating func add(item: BaseItem, count: Int = 1) {
        current[item, default: 0] += count
        total[item, default: 0] += count
    }

    mutating func add(artifact: ArtifactInstance) {
        let quality = artifacts[artifact.type, default: .junk]
        artifacts[artifact.type] = max(quality, artifact.quality)
    }
    
    mutating func remove(item: BaseItem, quantity: Int = 1) {
        let count = current[item] ?? 0
        current[item] = count - quantity
    }
    
    func quantity(_ item: BaseItem) -> Int {
        return current[item] ?? 0
    }
    
    func artifactInstance(_ artifact: Artifact) -> ArtifactInstance? {
        return quality(artifact).map { .init(type: artifact, quality: $0) }
    }
    
    func has(artifact: ArtifactInstance) -> Bool {
        guard let quality = artifacts[artifact.type] else {
            return false
        }
        return quality >= artifact.quality
    }
    
    func quality(_ artifact: Artifact) -> ItemQuality? {
        return artifacts[artifact]
    }
    
    func nextArtifactQuality(artifact: Artifact) -> ItemQuality? {
        guard let current = quality(artifact) else {
            return .junk
        }
        return current.next
    }
    
    func hasDiscovered(_ item: BaseItem) -> Bool {
        return total[item] != nil
    }
    
    var totalItemsCollected: Int {
        return total.reduce(0) { $0 + $1.value }
    }
    
    func totalItemsCollected(_ predicate: (BaseItem) -> Bool) -> Int {
        return total
            .filter { predicate($0.key) }
            .reduce(0) { $0 + $1.value }
    }

    /// Ordered list of equipped artifacts by slot index (for backward compatibility).
    var equippedArtifacts: [Artifact] {
        equippedSlots.sorted(by: { $0.key < $1.key }).map(\.value)
    }

    /// Slot contents for the given slot count. Returns [Artifact?] where index matches slot; nil = empty.
    func equippedSlotsContents(upToSlotCount count: Int) -> [ArtifactInstance?] {
        let artifacts = (0..<count).map { equippedSlots[$0] }
        return artifacts.map { artifact in
            if let artifact {
                return artifactInstance(artifact)
            } else {
                return nil
            }
        }
    }

    /// Equip an artifact into a specific slot (replaces whatever is in that slot).
    mutating func equip(_ artifact: Artifact, slot: Int) {
        guard artifactInstance(artifact) != nil, slot >= 0 else { return }
        equippedSlots[slot] = artifact
    }

    mutating func unequip(_ artifact: Artifact) {
        if let key = equippedSlots.first(where: { $0.value == artifact })?.key {
            equippedSlots.removeValue(forKey: key)
        }
    }

    mutating func unequip(slot: Int) {
        equippedSlots.removeValue(forKey: slot)
    }

    func equippedArtifact(_ type: Artifact) -> ArtifactInstance? {
        guard equippedSlots.values.contains(type),
              let quality = artifacts[type]
        else { return nil }
        return .init(type: type, quality: quality)
    }
}
