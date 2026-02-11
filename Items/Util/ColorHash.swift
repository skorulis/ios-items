import SwiftUI

/// Utility for deterministically mapping strings to colors from a fixed palette.
public enum ColorHash {
    /// Fixed palette of colors to choose from. Adjust or extend as needed.
    private static let palette: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .teal,
        .cyan,
        .blue,
        .indigo,
        .purple,
        .pink,
        .brown,
        .gray
    ]

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
}
