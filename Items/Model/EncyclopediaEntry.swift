//Created by Alexander Skorulis on 21/2/2026.

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

extension EncyclopediaEntry {
    static var root: Self {
        .init(
            title: "Encyclopedia",
            body: "",
            childItems: [
                Self.portal,
                Self.warehouse,
                Self.research,
                Self.essences,
                Self.artifacts,
            ]
        )
    }
    
    static var portal: Self {
        .init(
            title: "The Portal",
            body: """
            Your portal to another dimension works. When activated, it pulled an object from another dimension.
            
            Who knows what wonders this place contains, perhaps by studying the items you can slowly piece together what this dimension is.
            """,
            childItems: [Self.portalUpgrades, Self.sacrifices],
            iconImage: Image(systemName: "camera.aperture"),
        )
    }

    static var sacrifices: Self {
        .init(
            title: "Sacrifices",
            body: HelpStrings.recipeList,
            condition: .upgradePurchased(.sacrifices),
            childItems: []
        )
    }

    static var portalUpgrades: Self {
        .init(
            title: "Portal Upgrades",
            body: """
            You can use some of the items being pulled through the portal to add upgrades. This will help to access more of the hidden dimension
            """,
            condition: .itemsCreated(10),
            childItems: [],
            iconImage: Image(systemName: "arrow.up.circle.fill"),
        )
    }

    static var essences: Self {
        .init(
            title: "Essence",
            body: "All items contain essences that can be used to craft new items.",
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

// MARK: - Essences

extension EncyclopediaEntry {
    static func essenceEntry(_ essence: Essence) -> Self {
        return .init(
            title: essence.name,
            body: essence.encyclopediaText,
            condition: .essenceUnlocked(essence),
            childItems: [],
            icon: {
                EssenceView(essence: essence)
            }
        )
    }
}

private extension Essence {
    var encyclopediaText: String {
        // TODO
        name
    }
}
