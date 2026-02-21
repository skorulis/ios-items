//Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

nonisolated enum Essence: Identifiable, Hashable, Codable, CaseIterable {
    
    case dark
    case earth
    case life
    case light
    case magic
    case technology
    case wealth
    
    var id: Self { self }
    var name: String { String(describing: self).fromCaseName }
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
