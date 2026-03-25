// Created by Alexander Skorulis on 13/2/2026.

import Foundation
import Models

struct Laboratory: Codable {
    private var items: [Ingredient: ItemState] = [:]
    var currentResearch: CurrentResearch?

    func currentLevel(item: Ingredient) -> Int {
        items[item]?.level ?? 0
    }

    /// Highest research level reached across all items.
    var maxResearchLevel: Int {
        items.values.map(\.level).max() ?? 0
    }

    var totalLevels: Int {
        items.values.map(\.level).reduce(0, +)
    }

    mutating func set(level: Int, item: Ingredient) {
        items[item] = ItemState(level: level, accumulatedSeconds: 0)
    }

    func accumulatedSeconds(for item: Ingredient) -> TimeInterval {
        items[item]?.accumulatedSeconds ?? 0
    }

    mutating func setAccumulatedSeconds(_ seconds: TimeInterval, for item: Ingredient) {
        let level = items[item]?.level ?? 0
        items[item] = ItemState(level: level, accumulatedSeconds: seconds)
    }

    mutating func setState(level: Int, accumulatedSeconds: TimeInterval, for item: Ingredient) {
        items[item] = ItemState(level: level, accumulatedSeconds: accumulatedSeconds)
    }

    mutating func setCurrentResearch(item: Ingredient?, startDate: Date?) {
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
        var item: Ingredient
        var startDate: Date
    }
}
