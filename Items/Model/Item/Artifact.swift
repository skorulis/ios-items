//Created by Alexander Skorulis on 15/2/2026.

import Foundation

enum Artifact: Identifiable, Hashable, CaseIterable, Codable {
    
    case frictionlessGear
    
    var id: Self { self }
    
    var acronym: String {
        switch self {
        case .frictionlessGear:
            return "FG"
        }
    }
    
    var name: String {
        String(describing: self)
    }
}

struct ArtifactInstance {
    let type: Artifact
    let quality: ItemQuality
}
