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
        case .sacrifices, .sacrificesLevel2, .sacrificesLevel3, .sacrificesLevel4, .sacrificesLevel5:
            return Image(systemName: "flame.fill")
        case .artifactSlot, .artifactSlotLevel2, .artifactSlotLevel3: return Image(systemName: "square.stack.3d.up.fill")
        case .knowledgeSiphon, .knowledgeSiphonLevel2, .knowledgeSiphonLevel3, .knowledgeSiphonLevel4, .knowledgeSiphonLevel5: return Image(systemName: "book.fill")
        }
    }
}
