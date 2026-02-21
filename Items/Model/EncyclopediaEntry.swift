//Created by Alexander Skorulis on 21/2/2026.

import Foundation

struct EncyclopediaEntry {
    let title: String
    let body: String
    let childItems: [EncyclopediaEntry]
    
    static var root: Self {
        .init(
            title: "Encyclopedia",
            body: "",
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
            title: "Essences",
            body: "All items contain essences that can be used to craft new items.",
            childItems: Essence.allCases.map { Self.essenceEntry($0) }
        )
    }
}

// MARK: - Essences

extension EncyclopediaEntry {
    static func essenceEntry(_ essence: Essence) -> Self {
        return .init(title: essence.name, body: essence.encyclopediaText, childItems: [])
    }
}

private extension Essence {
    var encyclopediaText: String {
        // TODO
        name
    }
}
