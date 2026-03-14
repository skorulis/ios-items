// Created for offline creation support.

import Foundation

struct OfflineState: Codable, Equatable {
    var lastBackgroundedAt: Date?
    var automationEnabled: Bool = false
    
    mutating func updateBackgroundedTime() {
        self.lastBackgroundedAt = Date()
    }
}
