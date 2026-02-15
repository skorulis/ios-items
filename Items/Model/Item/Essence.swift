//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

nonisolated enum Essence: Identifiable, Hashable, Codable {
    
    case life
    case wealth
    case magic
    case technology
    case light
    case dark
    case earth
    
    var id: Self { self }
}

extension Essence {
    var color: Color {
        switch self {
        case .life: return .green
        case .wealth: return .orange
        case .magic: return .blue
        case .technology: return .gray
        case .light: return .yellow
        case .dark: return .black
        case .earth: return .brown
        }
    }
}
