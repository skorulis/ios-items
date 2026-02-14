//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

enum ItemQuality {
    case junk
    case common
    case good
    case rare
    case exceptional
    
    var color: Color {
        switch self {
        case .junk:
            return .gray
        case .common:
            return .yellow
        case .good:
            return .green
        case .rare:
            return .blue
        case .exceptional:
            return .orange
        }
    }
}
