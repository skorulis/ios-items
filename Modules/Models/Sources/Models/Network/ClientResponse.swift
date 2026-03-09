//  Created by Alexander Skorulis on 9/3/2026.

import Foundation

// A response from the client
public enum ClientResponse: Codable {

    case items([BaseItem: Int])
    case makeItemResult(MakeItemResult)
}
