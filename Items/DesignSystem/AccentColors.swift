//Created by Alexander Skorulis on 19/2/2026.

import Foundation
import SwiftUI

public enum AccentColors {
    // MARK: - Core accents

    /// A lively, warm red.
    public static let coral = Color(red: 0.95, green: 0.37, blue: 0.33)
    /// A vivid orange with good legibility.
    public static let tangerine = Color(red: 0.99, green: 0.58, blue: 0.20)
    /// A cheerful golden yellow.
    public static let sunflower = Color(red: 0.99, green: 0.80, blue: 0.20)
    /// A fresh green that avoids neon harshness.
    public static let meadow = Color(red: 0.22, green: 0.70, blue: 0.44)
    /// A minty turquoise.
    public static let spearmint = Color(red: 0.38, green: 0.86, blue: 0.73)
    /// A modern teal.
    public static let atlantic = Color(red: 0.16, green: 0.67, blue: 0.72)
    /// A bright cyan.
    public static let sky = Color(red: 0.18, green: 0.78, blue: 0.99)
    /// A calm, saturated blue.
    public static let azure = Color(red: 0.18, green: 0.45, blue: 0.94)
    /// A deep indigo.
    public static let indigo = Color(red: 0.34, green: 0.34, blue: 0.84)
    /// A rich purple.
    public static let amethyst = Color(red: 0.57, green: 0.36, blue: 0.94)
    /// A playful pink.
    public static let flamingo = Color(red: 0.99, green: 0.42, blue: 0.63)
    /// An earthy brown.
    public static let chestnut = Color(red: 0.58, green: 0.39, blue: 0.27)
    /// A neutral gray accent.
    public static let slate = Color(red: 0.58, green: 0.62, blue: 0.67)

    // MARK: - Ordered palette

    /// Ordered palette used for deterministic color selection.
    /// Keep this list stable to preserve color assignments.
    public static let palette: [Color] = [
        coral,
        tangerine,
        sunflower,
        meadow,
        spearmint,
        atlantic,
        sky,
        azure,
        indigo,
        amethyst,
        flamingo,
        chestnut,
        slate,
    ]
}
