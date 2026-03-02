//Created by Alexander Skorulis on 10/2/2026.

import Foundation
import Knit
import KnitMacros

/// Class that creates new items
/// Functions in this class are non mutating and only return the result
final class ItemGeneratorService {
    
    private let mainStore: MainStore
    private let calculations: CalculationsService
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, calculations: CalculationsService) {
        self.mainStore = mainStore
        self.calculations = calculations
    }
    
    func make(recipe: Recipe) -> Result {
        let quality = selectQuality(recipe: recipe)

        let essenceBonuses = essenceBonuses(recipe: recipe)
        let options = BaseItem.allCases.filter { $0.quality == quality}
        
        let randomArray = RandomArray(items: options) { item in
            var chance: Double = 1
            for essence in item.essences {
                chance *= essenceBonuses[essence, default: 1]
            }
            return chance
        }
        
        guard let baseItem = randomArray.random else {
            fatalError("Could not find an appropriate item. \(quality.name)")
        }
        
        if let artifact = maybeConvertToArtifact(baseItem: baseItem) {
            return .artifact(artifact)
        }
        
        // Check if another item gets created based on double item chance
        let chance = calculations.doubleItemChance(item: baseItem)
        let roll = Double.random(in: 0...1)
        if roll < chance {
            return .base(baseItem, 2)
        }
        
        return .base(baseItem, 1)
    }
    
    private func selectQuality(recipe: Recipe) -> ItemQuality {
        let randomArray = RandomArray(items: ItemQuality.allCases) {
            switch $0 {
            case .junk: return 1
            case .common: return 0.5 * Double(recipe.count(quality: .junk))
            case .good: return 0.5 * Double(recipe.count(quality: .common))
            case .rare: return 0.5 * Double(recipe.count(quality: .good))
            case .exceptional: return 0.5 * Double(recipe.count(quality: .rare))
            }
        }
        return randomArray.random ?? .junk
    }
    
    private func maybeConvertToArtifact(baseItem: BaseItem) -> ArtifactInstance? {
        let itemLevel = mainStore.lab.currentLevel(item: baseItem)
        
        guard let type = baseItem.associatedArtifact,
              baseItem.availableResearch.isArtifactUnlocked(level: itemLevel),
              let targetQuality = mainStore.warehouse.nextArtifactQuality(artifact: type)
        else {
            return nil
        }
        
        let chance = calculations.artifactChance(quality: targetQuality, researchLevel: itemLevel)
        guard Double.random(in: 0..<1) < chance else {
            return nil
        }
        
        return ArtifactInstance(type: type, quality: targetQuality)
    }
    
    private func essenceBonuses(recipe: Recipe) -> [Essence: Double] {
        return recipe.items.reduce([:]) { partialResult, item in
            var mutableResult = partialResult
            for essence in item.essences {
                mutableResult[essence, default: 1] += 1
            }
            return mutableResult
        }
    }
}

// MARK: - Inner Types

extension ItemGeneratorService{
    
    enum Result {
        case base(BaseItem, Int)
        case artifact(ArtifactInstance)
    }
}

