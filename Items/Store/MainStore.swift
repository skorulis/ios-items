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
    
    @Published var recipes: Recipes {
        didSet {
            try! self.store.set(codable: recipes, forKey: Self.recipesKey)
        }
    }
    @Published var lab = Laboratory() {
        didSet {
            try! self.store.set(codable: lab, forKey: Self.labKey)
        }
    }
    
    @Published var achievements: Achievements {
        didSet {
            try! self.store.set(codable: achievements, forKey: Self.achievementsKey)
        }
    }

    @Published var portalUpgrades: PortalUpgrades {
        didSet {
            try! self.store.set(codable: portalUpgrades, forKey: Self.portalUpgradesKey)
        }
    }
    
    @Published var concepts: Concepts {
        didSet {
            try! self.store.set(codable: concepts, forKey: Self.conceptsKey)
        }
    }

    @Published var notifications: Notifications {
        didSet {
            try? self.store.set(codable: notifications, forKey: Self.notificationsKey)
        }
    }

    @Published var offlineState: OfflineState {
        didSet {
            try? self.store.set(codable: offlineState, forKey: Self.offlineStateKey)
        }
    }

    private let store: PKeyValueStore
    private static let achievementsKey = "MainStore.achievements"
    private static let offlineStateKey = "MainStore.offlineState"
    private static let portalUpgradesKey = "MainStore.portalUpgrades"
    private static let conceptsKey = "MainStore.concepts"
    private static let labKey = "MainStore.lab"
    private static let notificationsKey = "MainStore.notifications"
    private static let recipesKey = "MainStore.recipes"
    private static let statisticsKey = "MainStore.statistics"
    private static let warehouseKey = "MainStore.warehouse"
    
    @Resolvable<BaseResolver>
    init(store: PKeyValueStore) {
        self.store = store

        self.warehouse = (try? store.codable(forKey: Self.warehouseKey)) ?? Warehouse()
        self.statistics = (try? store.codable(forKey: Self.statisticsKey)) ?? Statistics()
        self.lab = (try? store.codable(forKey: Self.labKey)) ?? Laboratory()
        self.achievements = (try? store.codable(forKey: Self.achievementsKey)) ?? Achievements()
        self.portalUpgrades = (try? store.codable(forKey: Self.portalUpgradesKey)) ?? PortalUpgrades()
        self.recipes = (try? store.codable(forKey: Self.recipesKey)) ?? Recipes()
        self.concepts = (try? store.codable(forKey: Self.conceptsKey)) ?? Concepts()
        self.notifications = (try? store.codable(forKey: Self.notificationsKey)) ?? Notifications()
        self.offlineState = (try? store.codable(forKey: Self.offlineStateKey)) ?? OfflineState()
    }
}
