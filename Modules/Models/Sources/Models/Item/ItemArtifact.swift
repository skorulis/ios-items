// Created by Alexander Skorulis on 15/2/2026.

import Foundation

public extension BaseItem {
    var associatedArtifact: Artifact? {
        switch self {
        case .gear:
            return .frictionlessGear
        case .hourglass:
            return .eternalHourglass
        case .quartzCrystal:
            return .chargedQuartz
        case .copperFlorin:
            return .luckyCoin
        case .lens:
            return .perfectLens
        case .potionFlask:
            return .essenceFlask
        case .humanSkull:
            return .skullOfStHermain
        default:
            return nil
        }
    }
}

public extension Artifact {
    var baseItem: BaseItem {
        switch self {
        case .frictionlessGear: return .gear
        case .eternalHourglass: return .hourglass
        case .chargedQuartz: return .quartzCrystal
        case .luckyCoin: return .copperFlorin
        case .perfectLens: return .lens
        case .sacrificalSkull: return .humanSkull
        case .essenceFlask: return .potionFlask
        case .skullOfStHermain: return .humanSkull
        }
    }
}
