// Created by Alexander Skorulis on 18/3/2026.

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var margin: CGFloat?
}

extension View {
    func margin(_ value: CGFloat = .margin) -> some View {
        self
            .padding(.horizontal, value)
            .environment(\.margin, value)
    }
}

extension CGFloat {
    static let margin: CGFloat = 16
}
