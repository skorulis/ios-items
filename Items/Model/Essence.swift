//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

nonisolated enum Essence: Identifiable, Hashable {
    
    case organic
    case magic
    case technology
    case light
    case dark
    
    var id: Self { self }
}

extension Essence {
    var color: Color {
        switch self {
        case .organic: return .green
        case .magic: return .blue
        case .technology: return .gray
        case .light: return .yellow
        case .dark: return .black
        }
    }
}
