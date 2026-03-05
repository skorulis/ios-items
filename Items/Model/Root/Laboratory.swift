//Created by Alexander Skorulis on 13/2/2026.

import Foundation

struct Laboratory: Codable {
    private var items: [BaseItem: ItemState] = [:]
    var currentResearch: CurrentResearch?
    
    func currentLevel(item: BaseItem) -> Int {
        items[item]?.level ?? 0
    }
    
    mutating func set(level: Int, item: BaseItem) {
        items[item] = ItemState(level: level, accumulatedSeconds: 0)
    }
    
    func accumulatedSeconds(for item: BaseItem) -> TimeInterval {
        items[item]?.accumulatedSeconds ?? 0
    }
    
    mutating func setAccumulatedSeconds(_ seconds: TimeInterval, for item: BaseItem) {
        let level = items[item]?.level ?? 0
        items[item] = ItemState(level: level, accumulatedSeconds: seconds)
    }
    
    mutating func setState(level: Int, accumulatedSeconds: TimeInterval, for item: BaseItem) {
        items[item] = ItemState(level: level, accumulatedSeconds: accumulatedSeconds)
    }
    
    mutating func setCurrentResearch(item: BaseItem?, startDate: Date?) {
        if let item, let startDate {
            currentResearch = CurrentResearch(item: item, startDate: startDate)
        } else {
            currentResearch = nil
        }
    }
}

// MARK: - Inner Types

extension Laboratory {
    struct ItemState: Codable {
        var level: Int
        var accumulatedSeconds: TimeInterval
    }

    struct CurrentResearch: Codable {
        var item: BaseItem
        var startDate: Date
    }
}
