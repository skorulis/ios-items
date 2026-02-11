//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Class that creates new items
final class ItemGeneratorService {
    
    
    func make() -> BaseItem {
        return BaseItem.allCases.randomElement()!
    }
}
