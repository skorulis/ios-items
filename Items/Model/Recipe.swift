//Created by Alexander Skorulis on 12/2/2026.

import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    var id = UUID()
    
    var items: [BaseItem]
    
    static var empty: Self { .init(items: []) }
    
    func count(quality: ItemQuality) -> Int {
        items.filter { $0.quality == quality }.count
    }
}
