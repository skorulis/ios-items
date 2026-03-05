//Created by Alexander Skorulis on 5/3/2026.

import Foundation

enum Bonus {
    case researchSpeed(Int)
    
    var text: String {
        switch self {
        case let .researchSpeed(int):
            return "Boost research speed by \(int)%"
        }
        
    }
}
