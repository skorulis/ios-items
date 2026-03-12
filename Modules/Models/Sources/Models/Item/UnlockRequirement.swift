// Created by Alexander Skorulis on 22/2/2026.

import Foundation

private let unlockRequirementNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

private func formatCount(_ value: Int64) -> String {
    unlockRequirementNumberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

public enum UnlockRequirement: Codable {
    case itemsCreated(Int64)
    case itemsSacrificed(Int64)
    /// Times a sacrifice yielded two items at once (double creation).
    case doubleItemCreations(Int64)
    case totalResearch(Int64)
    case maxResearchLevel(Int64)
    case commonItemsCreated(Int64)

    /// A specific base item has been discovered.
    case itemDiscovered(BaseItem)

    // How many essences have been unlocked
    case essencesUnlocked(Int64)

    // If a specific essence has been unlocked
    case essenceUnlocked(Essence)

    /// Number of distinct artifacts discovered (at any quality).
    case artifactsUnlocked(Int64)

    /// A specific artifact has been discovered (at any quality).
    case artifactUnlocked(Artifact)

    /// A specific portal upgrade has been purchased.
    case upgradePurchased(PortalUpgrade)

    /// Number of portal upgrades purchased (any upgrades).
    case upgradesPurchased(Int64)

    /// A specific achievement has been unlocked.
    case achievementUnlocked(Achievement)
}

public extension UnlockRequirement {
    var description: String {
        switch self {
        case let .itemsCreated(count):
            return "Create \(formatCount(count)) items"
        case let .itemsSacrificed(count):
            return "Sacrifice \(formatCount(count)) item\(count == 1 ? "" : "s")"
        case let .doubleItemCreations(count):
            return "Create multiple items at once \(formatCount(count)) time\(count == 1 ? "" : "s")"
        case let .totalResearch(count):
            return "Complete \(formatCount(count)) levels of research"
        case let .maxResearchLevel(level):
            return "Reach research level \(formatCount(level)) on any item"
        case let .commonItemsCreated(count):
            return "Create \(formatCount(count)) common items"
        case let .itemDiscovered(item):
            return "\(item.name) discovered"
        case let .essencesUnlocked(count):
            return "\(formatCount(count)) Essences discovered"
        case let .essenceUnlocked(essence):
            return "\(essence.name) discovered"
        case let .artifactsUnlocked(count):
            return "Discover \(formatCount(count)) artifact\(count == 1 ? "" : "s")"
        case let .artifactUnlocked(artifact):
            return "\(artifact.name) discovered"
        case let .upgradePurchased(upgrade):
            return "Purchase \(upgrade.name)"
        case let .upgradesPurchased(count):
            return "Purchase \(formatCount(count)) portal upgrade\(count == 1 ? "" : "s")"
        case let .achievementUnlocked(achievement):
            return "Unlock \(achievement.name)"
        }
    }
}
