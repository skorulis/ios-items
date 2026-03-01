//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

enum ItemQuality: Codable, CaseIterable {
    case junk
    case common
    case good
    case rare
    case exceptional
    
    var next: ItemQuality? {
        switch self {
        case .junk: return .common
        case .common: return .good
        case .good: return .rare
        case .rare: return .exceptional
        case .exceptional: return nil
        }
    }
    
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
    
    var name: String {
        String(describing: self).capitalized
    }
    
    var artifactChanceMultiplier: Double {
        switch self {
        case .junk:
            return 1
        case .common:
            return 0.2
        case .good:
            return 0.05
        case .rare:
            return 0.01
        case .exceptional:
            return 0.001
        }
    }
}

extension ItemQuality: Comparable {}
