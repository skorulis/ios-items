//Created by Alexander Skorulis on 21/2/2026.

import Foundation

struct EncyclopediaEntry {
    let title: String
    let body: String
    let condition: UnlockRequirement?
    let childItems: [EncyclopediaEntry]
    
    init(
        title: String,
        body: String,
        condition: UnlockRequirement? = nil,
        childItems: [EncyclopediaEntry] = [],
    ) {
        self.title = title
        self.body = body
        self.condition = condition
        self.childItems = childItems
    }
    
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
}

// MARK: - Root child items

extension EncyclopediaEntry {
    static var portal: Self {
        .init(
            title: "The Portal",
            body: """
            Your portal to another dimension works. When activated, it pulled an object from another dimension.
            
            Who knows what wonders this place contains, perhaps by studying the items you can slowly piece together what this dimension is.
            """,
            childItems: []
        )
    }

    static var essences: Self {
        .init(
            title: "Essence",
            body: "All items contain essences that can be used to craft new items.",
            condition: .essencesUnlocked(1),
            childItems: Essence.allCases.map { Self.essenceEntry($0) }
        )
    }
    
    static var warehouse: Self {
        .init(
            title: "Warehouse",
            body: HelpStrings.warehouse,
        )
    }

    static var research: Self {
        .init(
            title: "Research",
            body: HelpStrings.research,
        )
    }

    static var artifacts: Self {
        .init(
            title: "Artifacts",
            body: HelpStrings.artifacts,
            condition: .artifactsUnlocked(1),
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
            childItems: []
        )
    }
}

private extension Essence {
    var encyclopediaText: String {
        // TODO
        name
    }
}
