// Created by Alexander Skorulis on 23/3/2026.

import Foundation
import Models
import SwiftUI

extension GolemType {

    var image: Image? {
        switch self {
        case .clay:
            return Image(systemName: "figure.stand")
        case .iron:
            return Image(systemName: "shield.lefthalf.filled")
        case .crystal:
            return Image(systemName: "sparkles")
        }
    }
}
