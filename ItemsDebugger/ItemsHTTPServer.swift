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
        
        app.get("item") { _ async throws -> Response in
            guard let payload = await clients.send(request: .getItems) else {
                throw Abort(.serviceUnavailable, reason: "No client connected or no response received")
            }
            
            return try Self.response(payload: payload)
        }
        
        app.get("artifacts") { _ async throws -> Response in
            guard let payload = await clients.send(request: .getArtifacts) else {
                throw Abort(.serviceUnavailable, reason: "No client connected or no response received")
            }
            
            return try Self.response(payload: payload)
        }
        
        app.get("actions") { _ async throws -> Response in
            guard let payload = await clients.send(request: .getActions) else {
                throw Abort(.serviceUnavailable, reason: "No client connected or no response received")
            }
            
            return try Self.response(payload: payload)
        }
    }
    
    static func response(payload: ItemsClientResponse.Payload) throws -> Response {
        let converted = convert(payload: payload)
        let data = try JSONEncoder().encode(converted)
        var headers = HTTPHeaders()
        headers.contentType = .json
        return Response(status: .ok, headers: headers, body: .init(data: data))
    }
    
    static func convert(payload: ItemsClientResponse.Payload) -> Codable {
        switch payload {
        case let .items(items):
            return Dictionary(uniqueKeysWithValues: items.map { (key, value) in
                // In this example, we convert the integer key to a string key
                return (String(describing: key), value)
            })
        case let .makeItemResult(makeItemResult):
            return makeItemResult
        case let .actions(actions):
            return actions.map { action in
                return Link(
                    href: action.href,
                    action: "POST",
                )
            }
        case let .artifacts(artifacts):
            return Dictionary(uniqueKeysWithValues: artifacts.map { (artifact, quality) in
                (
                    String(describing: artifact),
                    quality.name
                )
            })
        }
    }
}

extension GameAction {
    var href: String {
        switch self {
        case .makeItem:
            return "/make"
        }
    }
}
