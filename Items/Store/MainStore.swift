// Created by Alexander Skorulis on 10/2/2026.

import ASKCore
import Combine
import Foundation
import Models
import Knit
import KnitMacros

// swiftlint:disable force_try
final class MainStore: ObservableObject {
    @Published var warehouse: Warehouse {
        didSet {
            try! self.store.set(codable: warehouse, forKey: Self.warehouseKey)
        }
    }

    @Published var tradingPost: TradingPost {
        didSet {
            try? self.store.set(codable: tradingPost, forKey: Self.tradingPostKey)
        }
    }

    @Published var statistics: Statistics {
        didSet {
            try! self.store.set(codable: statistics, forKey: Self.statisticsKey)
        }
    }

    @Published var sacrifices: Sacrifices {
        didSet {
            try! self.store.set(codable: sacrifices, forKey: Self.sacrificesPersistenceKey)
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

    @Published var golems: Golems {
        didSet {
            try! self.store.set(codable: golems, forKey: Self.golemsKey)
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

    @Published var mapLocations: MapLocations {
        didSet {
            try? self.store.set(codable: mapLocations, forKey: Self.mapLocationsKey)
        }
    }

    @Published var userInfo: UserInfo {
        didSet {
            try! self.store.set(codable: userInfo, forKey: Self.userInfoKey)
        }
    }

    private let store: PKeyValueStore
    private static let achievementsKey = "MainStore.achievements"
    private static let offlineStateKey = "MainStore.offlineState"
    private static let portalUpgradesKey = "MainStore.portalUpgrades"
    private static let golemsKey = "MainStore.golemsKey"
    private static let conceptsKey = "MainStore.concepts"
    private static let labKey = "MainStore.lab"
    private static let notificationsKey = "MainStore.notifications"
    /// UserDefaults key kept as `MainStore.recipes` for existing installs.
    private static let sacrificesPersistenceKey = "MainStore.recipes"
    private static let statisticsKey = "MainStore.statistics"
    private static let warehouseKey = "MainStore.warehouse"
    private static let tradingPostKey = "MainStore.tradingPost"
    private static let mapLocationsKey = "MainStore.mapLocations"
    private static let userInfoKey = "MainStore.userInfo"

    @Resolvable<BaseResolver>
    init(store: PKeyValueStore) {
        self.store = store

        self.warehouse = (try? store.codable(forKey: Self.warehouseKey)) ?? Warehouse()
        self.tradingPost = (try? store.codable(forKey: Self.tradingPostKey)) ?? TradingPost()
        self.statistics = (try? store.codable(forKey: Self.statisticsKey)) ?? Statistics()
        self.lab = (try? store.codable(forKey: Self.labKey)) ?? Laboratory()
        self.achievements = (try? store.codable(forKey: Self.achievementsKey)) ?? Achievements()
        var loadedPortalUpgrades = (try? store.codable(forKey: Self.portalUpgradesKey)) ?? PortalUpgrades()
        if !loadedPortalUpgrades.purchased.contains(.portalUnlocked) {
            loadedPortalUpgrades.purchased.insert(.portalUnlocked)
        }
        self.portalUpgrades = loadedPortalUpgrades
        self.golems = (try? store.codable(forKey: Self.golemsKey)) ?? Golems()
        self.sacrifices = (try? store.codable(forKey: Self.sacrificesPersistenceKey)) ?? Sacrifices()
        self.concepts = (try? store.codable(forKey: Self.conceptsKey)) ?? Concepts()
        self.notifications = (try? store.codable(forKey: Self.notificationsKey)) ?? Notifications()
        self.offlineState = (try? store.codable(forKey: Self.offlineStateKey)) ?? OfflineState()
        self.mapLocations = (try? store.codable(forKey: Self.mapLocationsKey)) ?? MapLocations()
        if let existingUser: UserInfo = (try? store.codable(forKey: Self.userInfoKey)) {
            self.userInfo = existingUser
        } else {
            self.userInfo = UserInfo()
            try? self.store.set(codable: userInfo, forKey: Self.userInfoKey)
        }
    }
}
// swiftlint:enable force_try

extension MainStore {
    var activeBonuses: [Bonus] {
        let fromAchievements = Achievement.allCases
            .filter { achievements.unlocked.contains($0) }
            .compactMap(\.bonus)

        let artifacts = self.warehouse.artifactBonuses
        return fromAchievements + portalUpgrades.bonuses + artifacts
    }
}
