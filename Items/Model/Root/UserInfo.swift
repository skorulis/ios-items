// Created by Alexander Skorulis on 22/3/2026.

import Foundation

/// Persisted player identity for this installation until a formal account system exists.
struct UserInfo: Codable, Equatable {
    /// Stable identifier for analytics, sync, or future sign-in linking.
    var localId: UUID

    init(localId: UUID = UUID()) {
        self.localId = localId
    }
}
