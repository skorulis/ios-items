// Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Models
import Vapor

private func parseClientResponse(_ data: Data) -> ItemsClientResponse? {
    try? JSONDecoder().decode(ItemsClientResponse.self, from: data)
}

/// WebSocket server using [Vapor](https://github.com/vapor/vapor).
enum WebSocketServer {

    static let defaultPort = 8765

    /// Starts the WebSocket server and blocks forever. Listens on all interfaces (0.0.0.0) so devices on the network can connect.
    /// - Parameter connectedClients: If provided, the latest connection is tracked here and can be sent messages from other threads.
    static func run(port: Int = defaultPort, connectedClients: ConnectedClient) throws {
        let env = try Environment.detect()
        let app = Application(env)
        defer { app.shutdown() }

        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = port

        let clients = connectedClients
        let server = ItemsHTTPServer(clients: clients)
        server.run(app: app)

        app.webSocket("") { _, ws in
            clients.setConnection(ws)
            print("Client connected")

            ws.onText { ws, text in
                let data = Data(text.utf8)
                guard let response = parseClientResponse(data) else {
                    print("WebSocketServer decode error for: \(text)")
                    return
                }
                clients.handle(response: response)
                switch response.payload {
                case let .items(itemsWithCount):
                    if itemsWithCount.isEmpty {
                        print("Client items: (empty)")
                    } else {
                        print("Client items:")
                        for (item, count) in itemsWithCount.sorted(by: { $0.key.name < $1.key.name }) {
                            print("  \(item.name): \(count)")
                        }
                    }
                case let .makeItemResult(result):
                    switch result {
                    case let .base(item, quantity):
                        print("Created item: \(item.name) x\(quantity)")
                    case let .artifact(artifact):
                        print("Created artifact: \(artifact.name)")
                    }
                case let .artifacts(artifacts):
                    print("Client artifacts:")
                    for (artifact, quality) in artifacts.sorted(by: { $0.key.name < $1.key.name }) {
                        print("  \(artifact.name): \(quality.name)")
                    }
                case let .achievements(completed, incomplete):
                    print("Client achievements: \(completed.count) completed, \(incomplete.count) incomplete")
                case let .error(message):
                    print("Client error: \(message)")
                default:
                    print("----")
                }
            }

            ws.onBinary { ws, buffer in
                print("Binary")
                // ws.send(buffer, opcode: .binary)
            }

            ws.onClose.whenComplete { _ in
                clients.remove(ws)
                print("Connection closed")
            }
        }

        print("WebSocket server listening on port \(port)")
        try app.run()
    }
}
