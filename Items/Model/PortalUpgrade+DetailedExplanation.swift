// Created by Alexander Skorulis on 17/3/2026.

import Foundation
import Models

// swiftlint:disable line_length
extension PortalUpgrade {

    var detailedExplanation: DefaultDialogContent.Model {
        switch self {
        case .portalUnlocked:
            return .init(
                bodyText: """
                Opening the portal to access an entirely new dimension
                """,
                title: "Portal Unlocked"
            )
        case .portalAutomation, .portalAutomationLevel2, .portalAutomationLevel3, .portalAutomationLevel4, .portalAutomationLevel5:
            return .init(
                bodyText: """
            Portal Automation automatically pulls items out of the portal so you don't have to tap each time. Items will move into your warehouse as they arrive.
            """,
                title: "Automation"
            )
        case .portalDuplication, .portalDuplicationLevel2, .portalDuplicationLevel3, .portalDuplicationLevel4, .portalDuplicationLevel5:
            return .init(
                bodyText: """
                Portal Duplication gives a chance for created items to duplicate.
                Each level adds 2% duplicate chance, increasing total output over time.
                """,
                title: "Duplication"
            )
        case .researchLab, .researchLabLevel2, .researchLabLevel3, .researchLabLevel4, .researchLabLevel5:
            return .init(bodyText: HelpStrings.research, title: "Research")
        case .sacrifices, .sacrificesLevel2, .sacrificesLevel3, .sacrificesLevel4, .sacrificesLevel5:
            return .init(bodyText: HelpStrings.sacrifices, title: "Sacrifices")
        case .crafting:
            return .init(
                bodyText: """
                Crafting unlocks the Equipment tab in the Warehouse so you can create equipment.
                New recipes may be discovered when summoning items from the portal.
                """,
                title: "Crafting"
            )
        case .recycling, .recyclingLevel2, .recyclingLevel3, .recyclingLevel4, .recyclingLevel5:
            return .init(
                bodyText: """
                Recycling gives a chance for crafting to succeed without consuming the recipe materials.
                Each level adds +1% to the no-consume chance.
                """,
                title: "Recycling"
            )
        case .sacrificesPower, .sacrificesPowerLevel2, .sacrificesPowerLevel3, .sacrificesPowerLevel4, .sacrificesPowerLevel5:
            return .init(
                bodyText: """
                Sacrifice Power increases the effectiveness of each sacrifice by 10% per level.
                Higher levels multiply your sacrifice output and make each slot more impactful.
                """,
                title: "Sacrifice Power"
            )
        case .artifactSlot, .artifactSlotLevel2, .artifactSlotLevel3:
            return .init(bodyText: HelpStrings.artifacts, title: "Artifacts")
        case .knowledgeSiphon, .knowledgeSiphonLevel2, .knowledgeSiphonLevel3, .knowledgeSiphonLevel4, .knowledgeSiphonLevel5:
            return .init(bodyText: """
            Knowledge Siphon lets you use junk-quality books to rush research progress.
            """)
        case .offlineProgress, .offlineProgressLevel2, .offlineProgressLevel3, .offlineProgressLevel4, .offlineProgressLevel5:
            return .init(bodyText: """
            Offline Progress lets the portal keep working when the app is closed or in the background. Each level adds up to 60 minutes of offline progress, so higher levels let you accumulate more items while away.
            """)
        case .mapLocations:
            return .init(bodyText: """
            This upgrade unlocks the ability to point the portal at specific locations on the map, influencing which kinds of items are more likely to appear.
            """)
        case .tradingPost:
            return .init(bodyText: HelpStrings.tradingPost, title: "Trading Post")
        case .tradingPostLevel2:
            return .init(bodyText: HelpStrings.tradingPostLevel2, title: "Trading Post II")
        case .tradingPostLevel3:
            return .init(bodyText: HelpStrings.tradingPostLevel3, title: "Trading Post III")
        case .golems:
            return .init(
                bodyText: """
                Golems are summoned helpers that can be sent into the portal as agents.
                Purchasing this upgrade unlocks the Golems tab for managing your golems.
                """,
                title: "Golems"
            )
        case .golemMissionSlotsLevel2, .golemMissionSlotsLevel3, .golemMissionSlotsLevel4, .golemMissionSlotsLevel5:
            return .init(
                bodyText: """
                Each Golem Missions upgrade adds another concurrent mission slot on the Missions tab.
                With all four upgrades unlocked, you can run up to five golem missions at the same time.
                """,
                title: "Golem Missions"
            )
        }
    }
}
// swiftlint:enable line_length
