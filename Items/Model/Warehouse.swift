//Created by Alexander Skorulis on 10/2/2026.

import Foundation

struct Warehouse: Codable {
    // Current item storage
    private var current: [BaseItem: Int] = [:]
    
    // Discovered artifacts
    private var artifacts: [Artifact: ItemQuality] = [:]
    
    // Total items that have been found
    private var total: [BaseItem: Int] = [:]
    
    // New discoveries not yet viewed (persisted)
    private var newItems: Set<BaseItem> = []
    private var newArtifacts: Set<Artifact> = []
    
    mutating func add(item: BaseItem, count: Int = 1) {
        let wasNewDiscovery = (total[item] ?? 0) == 0
        current[item, default: 0] += count
        total[item, default: 0] += count
        if wasNewDiscovery {
            newItems.insert(item)
        }
    }
    
    mutating func add(artifact: ArtifactInstance) {
        let wasNew = artifacts[artifact.type] == nil
        let quality = artifacts[artifact.type, default: .junk]
        artifacts[artifact.type] = max(quality, artifact.quality)
        if wasNew {
            newArtifacts.insert(artifact.type)
        }
    }
    
    mutating func markViewed(item: BaseItem) {
        newItems.remove(item)
    }
    
    mutating func markViewed(artifact: Artifact) {
        newArtifacts.remove(artifact)
    }
    
    func isNew(item: BaseItem) -> Bool {
        newItems.contains(item)
    }
    
    func isNew(artifact: Artifact) -> Bool {
        newArtifacts.contains(artifact)
    }
    
    var newDiscoveriesCount: Int {
        newItems.count + newArtifacts.count
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
}
