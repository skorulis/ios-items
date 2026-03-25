//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

public enum MakeItemResult: Codable, Equatable {
    case base(Ingredient, Int)
    case artifact(ArtifactInstance)
}
