// Created by Alexander Skorulis on 21/2/2026.

import Foundation
import Models
import SwiftUI

struct EncyclopediaEntry {
    let title: String
    let body: String
    let condition: UnlockRequirement?
    let childItems: [EncyclopediaEntry]
    /// Leading icon for the row when unlocked. Type-erased so each entry can supply any SwiftUI view.
    let icon: AnyView?

    init(
        title: String,
        body: String,
        condition: UnlockRequirement? = nil,
        childItems: [EncyclopediaEntry] = [],
        icon: AnyView? = nil
    ) {
        self.title = title
        self.body = body
        self.condition = condition
        self.childItems = childItems
        self.icon = icon
    }

    /// Whether this entry provides a row icon (unlocked rows show it via `ChevronRow` leading).
    var hasIcon: Bool { icon != nil }
}

// MARK: - Icon builder initializer

extension EncyclopediaEntry {
    /// Creates an entry with a SwiftUI icon built from a view builder.
    init<V: View>(
        title: String,
        body: String,
        condition: UnlockRequirement? = nil,
        childItems: [EncyclopediaEntry] = [],
        @ViewBuilder icon: () -> V
    ) {
        self.init(
            title: title,
            body: body,
            condition: condition,
            childItems: childItems,
            icon: AnyView(icon())
        )
    }

    init(
        title: String,
        body: String,
        condition: UnlockRequirement? = nil,
        childItems: [EncyclopediaEntry] = [],
        iconImage: Image,
    ) {
        self.init(
            title: title,
            body: body,
            condition: condition,
            childItems: childItems,
            icon: AnyView(
                iconImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            )
        )
    }
}

// MARK: - Root child items

// swiftlint:disable line_length
extension EncyclopediaEntry {
    static var root: Self {
        .init(
            title: "Encyclopedia",
            body: "",
            childItems: [
                Self.portal,
                Self.warehouse,
                Self.essences,
                Self.artifacts,
                Self.locations,
            ]
        )
    }

    static var locations: Self {
        .init(
            title: "Locations",
            body: "The portal can be tuned to draw items from different places in the dimension. Unlock and travel to new locations to discover unique items and essence biases.",
            condition: .upgradePurchased(.mapLocations),
            childItems: MapLocation.allCases.map { Self.locationEntry($0) },
            iconImage: Image(systemName: "map")
        )
    }

    static var portal: Self {
        .init(
            title: "The Portal",
            body: """
            Your portal to another dimension works. When activated, it pulled an object from another dimension.

            Who knows what wonders this place contains, perhaps by studying the items you can slowly piece together what this dimension is.
            """,
            childItems: [Self.research, Self.portalUpgrades, Self.sacrifices, Self.offlineProgress],
            iconImage: Image(systemName: "camera.aperture"),
        )
    }

    static var sacrifices: Self {
        .init(
            title: "Sacrifices",
            body: HelpStrings.sacrifices,
            condition: .upgradePurchased(.sacrifices),
            childItems: [],
            iconImage: Image(systemName: "pentagon"),
        )
    }

    static var portalUpgrades: Self {
        .init(
            title: "Portal Upgrades",
            body: """
            You can use some of the items that have been pulled through the portal to add upgrades.

            This will help to access more of the hidden dimension
            """,
            condition: .itemsCreated(10),
            childItems: [],
            iconImage: Image(systemName: "arrow.up.circle.fill"),
        )
    }

    static var offlineProgress: Self {
        .init(
            title: "Offline Progress",
            body: """
            Offline Progress lets the portal keep working when the app is closed or in the background. Each level adds up to 60 minutes of offline progress, so higher levels let you accumulate more items while away.
            """,
            condition: .upgradePurchased(.offlineProgress),
            childItems: [],
            iconImage: Image(systemName: "arrow.up.circle.badge.clock")
        )
    }

    static var essences: Self {
        .init(
            title: "Essence",
            body: "All items contain essences that can be used to craft new items. Essences are discovered by researching items.",
            condition: .essencesUnlocked(1),
            childItems: Essence.allCases.map { Self.essenceEntry($0) },
            icon: {
                HStack(spacing: -6) {
                    EssenceView(essence: .knowledge)
                    EssenceView(essence: .magic)
                }
            }
        )
    }

    static var warehouse: Self {
        .init(
            title: "Warehouse",
            body: HelpStrings.warehouse,
            iconImage: Image(systemName: "shippingbox"),
        )
    }

    static var research: Self {
        .init(
            title: "Research",
            body: HelpStrings.research,
            condition: .upgradePurchased(.researchLab),
            iconImage: Image(systemName: "flask"),
        )
    }

    static var artifacts: Self {
        .init(
            title: "Artifacts",
            body: HelpStrings.artifacts,
            condition: .artifactsUnlocked(1),
            iconImage: Image(systemName: "sparkles.2"),
        )
    }
}
// swiftlint:enable line_length

// MARK: - Locations

extension EncyclopediaEntry {
    static func locationEntry(_ location: MapLocation) -> Self {
        return .init(
            title: location.name,
            body: location.details.description,
            condition: .locationUnlocked(location),
            childItems: [],
            iconImage: Image(systemName: "mappin.circle")
        )
    }
}

// MARK: - Essences

extension EncyclopediaEntry {
    static func essenceEntry(_ essence: Essence) -> Self {
        return .init(
            title: essence.name,
            body: essence.description,
            condition: .essenceUnlocked(essence),
            childItems: [],
            icon: {
                EssenceView(essence: essence)
            }
        )
    }
}
