//Created by Alexander Skorulis on 9/3/2026.

import Models
import Foundation
import Vapor

final class ItemsHTTPServer {
    
    init() {}
    
    func run(app: Application, clients: ConnectedClients) {
        // HTTP endpoint to trigger a `makeItem` request on the connected client and return the JSON response.
        app.post("make") { _ async throws -> Response in
            guard let payload = await clients.send(request: .makeItem) else {
                throw Abort(.serviceUnavailable, reason: "No client connected or no response received")
            }
            
            return try Self.response(payload: payload)
        }    
    }
    
    static func response(payload: ItemsClientResponse.Payload) throws -> Response {
        let data = try JSONEncoder().encode(payload)
        var headers = HTTPHeaders()
        headers.contentType = .json
        return Response(status: .ok, headers: headers, body: .init(data: data))
    }
}
