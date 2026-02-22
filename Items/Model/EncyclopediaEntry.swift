//Created by Alexander Skorulis on 21/2/2026.

import Foundation

struct EncyclopediaEntry {
    let title: String
    let body: String
    let condition: UnlockRequirement?
    let childItems: [EncyclopediaEntry]
    
    static var root: Self {
        .init(
            title: "Encyclopedia",
            body: "",
            condition: nil,
            childItems: [
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
