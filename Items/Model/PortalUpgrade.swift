//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Models
import SwiftUI

/// App-specific extensions for `PortalUpgrade` that depend on UI or app-only models.
extension PortalUpgrade {

    var image: Image? {
        switch self {
        case .portalAutomation: return Image(systemName: "play.circle.fill")
        case .researchLab: return Image(systemName: "flask.fill")
        case .researchLabLevel2: return Image(systemName: "flask.fill")
        case .sacrifices: return Image(systemName: "flame.fill")
        case .artifactSlot, .artifactSlotLevel2, .artifactSlotLevel3: return Image(systemName: "square.stack.3d.up.fill")
        case .knowledgeSiphon, .knowledgeSiphonLevel2, .knowledgeSiphonLevel3, .knowledgeSiphonLevel4, .knowledgeSiphonLevel5: return Image(systemName: "book.fill")
        }
    }
}

extension PortalUpgrade {

    /// Requirements that must all be met before this upgrade becomes available.
    var requirements: [UnlockRequirement] {
        switch self {
        case .researchLabLevel2:
            return [.upgradePurchased(.researchLab)]
        case .artifactSlotLevel2:
            return [
                .upgradePurchased(.artifactSlot),
                .achievementUnlocked(.artifacts5),
            ]
        case .artifactSlotLevel3:
            return [.upgradePurchased(.artifactSlotLevel2)]
        case .knowledgeSiphon:
            return [.upgradePurchased(.researchLab)]
        case .knowledgeSiphonLevel2:
            return [.upgradePurchased(.knowledgeSiphon)]
        case .knowledgeSiphonLevel3:
            return [.upgradePurchased(.knowledgeSiphonLevel2)]
        case .knowledgeSiphonLevel4:
            return [.upgradePurchased(.knowledgeSiphonLevel3)]
        case .knowledgeSiphonLevel5:
            return [.upgradePurchased(.knowledgeSiphonLevel4)]
        default:
            return []
        }
    }
}

