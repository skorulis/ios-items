// Created by Alexander Skorulis on 13/2/2026.

import Foundation
import SwiftUI

public nonisolated enum Essence: Identifiable, Hashable, Codable, CaseIterable {
    case dark
    case earth
    case life
    case light
    case magic
    case technology
    case wealth
    case knowledge

    public var id: Self { self }
    public var name: String { String(describing: self).fromCaseName }
}

public extension Essence {
    var color: Color {
        switch self {
        case .life: return .green
        case .wealth: return .orange
        case .magic: return .blue
        case .technology: return .gray
        case .light: return .yellow
        case .dark: return .black
        case .earth: return .brown
        case .knowledge: return .cyan
        }
    }
}
