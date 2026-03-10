//Created by Alexander Skorulis on 11/3/2026.

import Foundation

// Standard error message
struct ItemsError: LocalizedError {
    let message: String
    
    var errorDescription: String? { message }
}
