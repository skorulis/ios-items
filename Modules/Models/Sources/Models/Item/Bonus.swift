// Created by Alexander Skorulis on 5/3/2026.

import Foundation

public enum Bonus {
    case researchSpeed(Int)
    case artifactSlots(Int)
    /// Extra sacrifice slots (not yet consumed by gameplay; reserved for future use).
    case sacrificeSlot(Int)
    case qualityBoost(Int, ItemQuality)
    case booksForResearch(ItemQuality)
    case artifactDiscovery(Int)

    public var text: String {
        switch self {
        case let .researchSpeed(int):
            return "Boost research speed by \(int)%"
        case let .artifactSlots(int):
            return "Add \(int) artifact slot"
        case let .sacrificeSlot(int):
            return "Add \(int) sacrifice slot\(int == 1 ? "" : "s")"
        case let .qualityBoost(amount, quality):
            return "Boost the chance to find \(quality.name) items by \(amount)%"
        case let .booksForResearch(quality):
            return "Use books to research \(quality.name) items"
        case let .artifactDiscovery(percent):
            return "Boost artifact discovery chance by \(percent)%"
        }
    }

    public var researchSpeedBoost: Int {
        switch self {
        case let .researchSpeed(int):
            return int
        default:
            return 0
        }
    }

    public var artifactSlotBoost: Int {
        switch self {
        case .artifactSlots(let int):
            return int
        default:
            return 0
        }
    }

    public var sacrificeSlotBoost: Int {
        switch self {
        case .sacrificeSlot(let int):
            return int
        default:
            return 0
        }
    }

    /// For qualityBoost case: (quality, percent). Nil for other bonus types.
    public var qualityBoostValue: (ItemQuality, Int)? {
        if case let .qualityBoost(amount, quality) = self {
            return (quality, amount)
        }
        return nil
    }

    /// Quality tier unlocked for book-based research. Nil for other bonus types.
    public var booksForResearchQuality: ItemQuality? {
        if case let .booksForResearch(quality) = self { return quality }
        return nil
    }
    
    public var artifactDiscoveryPercent: Int {
        if case let .artifactDiscovery(int) = self { return int }
        return 0
    }
}

public extension Array where Element == Bonus {
    var researchSpeed: Int {
        return self.map { $0.researchSpeedBoost }.reduce(0, +)
    }

    var artifactSlots: Int {
        return self.map { $0.artifactSlotBoost }.reduce(0, +)
    }
    
    var artifactDiscovery: Int {
        return self.map { $0.artifactDiscoveryPercent }.reduce(0, +)
    }

    /// Sum of quality boost percent per quality (e.g. [.common: 1] means +1% chance for common).
    var qualityBoosts: [ItemQuality: Int] {
        return self.compactMap(\.qualityBoostValue).reduce(into: [:]) { result, pair in
            result[pair.0, default: 0] += pair.1
        }
    }

    /// Highest quality tier that can use books for research. Nil if none unlocked.
    var maxBooksForResearchQuality: ItemQuality? {
        compactMap(\.booksForResearchQuality).max()
    }

    /// Whether books can be used to research items of the given quality (unlocked tier must be >= quality).
    func canUseBooksForResearch(quality: ItemQuality) -> Bool {
        guard let maxQuality = maxBooksForResearchQuality else { return false }
        return quality <= maxQuality
    }
}
