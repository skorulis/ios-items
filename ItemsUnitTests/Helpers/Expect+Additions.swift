//Created by Alexander Skorulis on 2/3/2026.

import Foundation
import Testing

func expectApproximate(
    _ actual: Double,
    _ expected: Double,
    tolerance: Double = 1e-9,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(abs(actual - expected) < tolerance, "\(actual) != \(expected)", sourceLocation: sourceLocation)
}
