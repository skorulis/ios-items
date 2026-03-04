//Created by Alexander Skorulis on 3/3/2026.

import Foundation

struct Achievements: Codable, Equatable {
    var unlocked: Set<Achievement> = []
    
    mutating func add(achievements: Set<Achievement>) {
        let missing = achievements.subtracting(unlocked)
        if !missing.isEmpty {
            unlocked = unlocked.union(missing)
        }
    }
}
