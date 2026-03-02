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
