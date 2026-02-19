import SwiftUI

/// Utility for deterministically mapping strings to colors from a fixed palette.
public enum ColorHash {
    /// Fixed palette of colors to choose from. Adjust or extend as needed.
    private static let palette: [Color] = AccentColors.palette

    /// Returns a color from the palette based on a stable hash of the given string.
    /// - Parameter string: The input used to choose a color.
    /// - Returns: A color selected deterministically from the palette.
    public static func color(for string: String) -> Color {
        let h = fnv1a64(string)
        let index = Int(h % UInt64(palette.count))
        return palette[index]
    }

    // MARK: - Stable hashing (FNV-1a 64-bit)

    /// FNV-1a 64-bit hash for stable, deterministic hashing across runs and platforms.
    /// This avoids using Swift's built-in `hashValue`, which is intentionally randomized.
    private static func fnv1a64(_ string: String) -> UInt64 {
        let fnvOffset: UInt64 = 0xcbf29ce484222325
        let fnvPrime: UInt64 = 0x100000001b3

        var hash = fnvOffset
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash &*= fnvPrime
        }
        return hash
    }
    
    static func gradient(for text: String) -> some ShapeStyle {
        // Use the same stable hash as ColorHash to keep assignments consistent.
        // Derive an index from FNV-1a directly for palette selection
        let raw = Self.fnv1a64(text)
        let palette = AccentColors.palette
        let c1 = palette[Int(raw % UInt64(palette.count))]
        let c2 = palette[Int((raw + 1) % UInt64(palette.count))]
        let c3 = palette[Int((raw + 2) % UInt64(palette.count))]
        // Soften the blend slightly
        let stops: [Gradient.Stop] = [
            .init(color: c1.opacity(0.95), location: 0.0),
            .init(color: c2.opacity(0.90), location: 0.55),
            .init(color: c3.opacity(0.95), location: 1.0),
        ]
        // Angular gradients look nice within circles; fall back to linear if preferred.
        return LinearGradient(
            gradient: Gradient(stops: stops), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

