//Created by Alexander Skorulis on 15/2/2026.

import Foundation

extension BaseItem {
    
    var associatedArtifact: Artifact? {
        switch self {
        case .gear:
            return .frictionlessGear
        case .hourglass:
            return .eternalHourglass
        case .copperFlorin:
            return .luckyCoin
        default:
            return nil
        }
    }
}

extension Artifact {
    var baseItem: BaseItem {
        switch self {
        case .frictionlessGear:
            return .gear
        case .eternalHourglass:
            return .hourglass
        case .luckyCoin:
            return .copperFlorin
        }
    }
}
