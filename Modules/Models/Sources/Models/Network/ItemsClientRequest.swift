//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

// Requests sent to the client
public enum ItemsClientRequest: Codable {

    case getItems
    case makeItem
}
