//Created by Alexander Skorulis on 12/2/2026.

import Foundation

struct Recipe: Identifiable {
    let id = UUID()
    
    var items: [BaseItem]
    
    func count(quality: ItemQuality) -> Int {
        items.filter { $0.quality == quality }.count
    }
}
