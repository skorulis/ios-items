//Created by Alexander Skorulis on 3/3/2026.

import Foundation

struct Achievements: Codable, Equatable {
    var unlocked: Set<Achievement> = []
    var new: Set<Achievement> = []
    
    mutating func add(achievements: Set<Achievement>) {
        let missing = achievements.subtracting(unlocked)
        if !missing.isEmpty {
            unlocked = unlocked.union(missing)
            new = new.union(missing)
        }
    }
    
    mutating func clearNewAchievements() {
        guard !new.isEmpty else { return }
        new = []
    }
}
