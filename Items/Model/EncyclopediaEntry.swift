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
                Self.warehouse,
                Self.essences,
            ]
        )
    }
}

// MARK: - Root child items

extension EncyclopediaEntry {
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
