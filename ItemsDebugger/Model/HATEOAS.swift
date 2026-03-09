//Created by Alexander Skorulis on 9/3/2026.

import Foundation

struct HATEOAS: Codable {
    let _links: [Link]
}

struct Link: Codable {
    let href: String
    let description: String
    let action: String
}
