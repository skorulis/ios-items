//Created by Alexander Skorulis on 10/2/2026.

import ASKCore
import Combine
import Foundation
import Knit
import KnitMacros

final class MainStore: ObservableObject {
    @Published var warehouse: Warehouse {
        didSet {
            try! self.store.set(codable: warehouse, forKey: Self.warehouseKey)
        }
    }
    
    @Published var statistics: Statistics {
        didSet {
            try! self.store.set(codable: statistics, forKey: Self.statisticsKey)
        }
    }
    
    @Published var recipes: [Recipe] = []
    @Published var lab = Laboratory() {
        didSet {
            try! self.store.set(codable: lab, forKey: Self.labKey)
        }
    }
    
    @Published var achievements: [Achievement] {
        didSet {
            try! self.store.set(codable: achievements, forKey: Self.achievementsKey)
        }
    }
    
    private let store: PKeyValueStore
    private static let achievementsKey = "MainStore.achievements"
    private static let labKey = "MainStore.lab"
    private static let recipesKey = "MainStore.recipes"
    private static let statisticsKey = "MainStore.statistics"
    private static let warehouseKey = "MainStore.warehouse"
    
    @Resolvable<BaseResolver>
    init(store: PKeyValueStore) {
        self.store = store
        
        self.warehouse = (try? store.codable(forKey: Self.warehouseKey)) ?? Warehouse()
        self.statistics = (try? store.codable(forKey: Self.statisticsKey)) ?? Statistics()
        self.lab = (try? store.codable(forKey: Self.labKey)) ?? Laboratory()
        self.achievements = (try? store.codable(forKey: Self.achievementsKey)) ?? []
    }
}
