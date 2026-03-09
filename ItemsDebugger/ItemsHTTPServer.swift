//Created by Alexander Skorulis on 9/3/2026.

import Models
import Foundation
import Vapor

final class ItemsHTTPServer {
    
    let clients: ConnectedClients
    
    init(clients: ConnectedClients) {
        self.clients = clients
    }
    
    func run(app: Application, ) {
        
        // Get the available actions that the client can perform
        app.get("actions") { _ async throws -> Response in
            let payload = try await self.getResponse(request: .getActions)
            return try Self.makeResponse(payload: payload)
        }
        
        app.post("make") { _ async throws -> Response in
            let payload = try await self.getResponse(request: .makeItem)
            return try Self.makeResponse(payload: payload)
        }
        
        app.get("items") { _ async throws -> Response in
            let payload = try await self.getResponse(request: .getItems)
            return try Self.makeResponse(payload: payload)
        }
        
        app.get("artifacts") { _ async throws -> Response in
            let payload = try await self.getResponse(request: .getArtifacts)
            return try Self.makeResponse(payload: payload)
        }
        
        app.get("upgrades") { _ async throws -> Response in
            let payload = try await self.getResponse(request: .getUpgrades)
            return try Self.makeResponse(payload: payload)
        }

        app.get("achievements") { _ async throws -> Response in
            let payload = try await self.getResponse(request: .getAchievements)
            return try Self.makeResponse(payload: payload)
        }

        app.post("upgrades/purchase") { request async throws -> Response in
            guard let id = try? request.query.get(String.self, at: "id") else {
                throw Abort(.badRequest, reason: "Missing query parameter: id")
            }
            guard let upgrade = PortalUpgrade(rawValue: id) else {
                throw Abort(.badRequest, reason: "Unknown upgrade id: \(id)")
            }
            let payload = try await self.getResponse(request: .purchaseUpgrade(upgrade))
            return try Self.makeResponse(payload: payload)
        }
    }
    
    private func getResponse(request: ItemsClientRequest.Payload) async throws -> ItemsClientResponse.Payload {
        guard let payload = await clients.send(request: request) else {
            throw Abort(.serviceUnavailable, reason: "No client connected or no response received")
        }
        return payload
    }
    
    static func makeResponse(payload: ItemsClientResponse.Payload) throws -> Response {
        if case let .error(message) = payload {
            throw Abort(.badRequest, reason: message)
        }
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
        case let .actions(actions, data):
            let actionLinks = actions.map { action in
                return Link(
                    href: action.href,
                    description: action.description,
                    action: "POST",
                )
            }
            let dataLinks = data.map { data in
                return Link(
                    href: data.href,
                    description: data.description,
                    action: "GET",
                )
            }
            
            return HATEOAS(_links: dataLinks + actionLinks)
        case let .artifacts(artifacts):
            return Dictionary(uniqueKeysWithValues: artifacts.map { (artifact, quality) in
                (
                    String(describing: artifact),
                    quality.name
                )
            })
        case let .upgrades(upgrades):
            return [
                "purchased": upgrades.purchased.map { HTTPPortalUpgrade(upgrade: $0) },
                "available": upgrades.available.map { HTTPPortalUpgrade(upgrade: $0) },
            ]
        case let .achievements(completed, incomplete):
            return [
                "completed": completed.map { HTTPAchievement(achievement: $0) },
                "incomplete": incomplete.map { HTTPAchievement(achievement: $0) },
            ]
        case .ok:
            return ["status": "ok"]
        case .error:
            fatalError("error payload should be handled in response(payload:)")
        }
    }
}

extension GameData {
    var href: String {
        switch self {
        case .items: return "/items"
        case .artifacts: return "/artifacts"
        case .upgrades: return "/upgrades"
        case .achievements: return "/achievements"
        }
    }
}

extension GameAction {
    var href: String {
        switch self {
        case .makeItem:
            return "/make"
        case .purchaseUpgrade:
            return "/upgrades/purchase{?id}"
        }
    }
}
