// Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Models
import Vapor

private func parseClientResponse(_ data: Data) -> ItemsClientResponse? {
    try? JSONDecoder().decode(ItemsClientResponse.self, from: data)
}

/// Thread-safe container for the current WebSocket connection (latest connection only).
final class ConnectedClients: @unchecked Sendable {
    private let lock = NSLock()
    private var client: Vapor.WebSocket?
    private var pendingResponses: [String: CheckedContinuation<ItemsClientResponse.Payload?, Never>] = [:]

    func setConnection(_ websocket: Vapor.WebSocket?) {
        lock.lock()
        defer { lock.unlock() }
        client = websocket
    }

    func remove(_ websocket: Vapor.WebSocket) {
        lock.lock()
        defer { lock.unlock() }
        if client === websocket {
            client = nil
        }
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return client != nil ? 1 : 0
    }

    func send(request payload: ItemsClientRequest.Payload) async -> ItemsClientResponse.Payload? {
        guard let websocket = client else {
            print("no client connected")
            return nil
        }
        let request = ItemsClientRequest(payload: payload)

        guard let data = try? JSONEncoder().encode(request) else {
            return nil
        }
        let string = String(data: data, encoding: .utf8) ?? ""

        return await withCheckedContinuation { continuation in
            lock.lock()
            pendingResponses[request.id] = continuation
            lock.unlock()

            websocket.eventLoop.execute {
                websocket.send(string)
            }
        }
    }

    func handle(response: ItemsClientResponse) {
        lock.lock()
        let continuation = pendingResponses.removeValue(forKey: response.id)
        lock.unlock()

        continuation?.resume(returning: response.payload)
    }

    /// Sends text to the connected client. Safe to call from any thread. No-op if no client.
    func sendToAll(_ text: String) {
        lock.lock()
        let websocket = client
        lock.unlock()
        guard let websocket else { return }
        websocket.eventLoop.execute {
            websocket.send(text)
        }
    }
}

/// WebSocket server using [Vapor](https://github.com/vapor/vapor).
enum WebSocketServer {

    static let defaultPort = 8765

    /// Starts the WebSocket server and blocks forever. Listens on all interfaces (0.0.0.0) so devices on the network can connect.
    /// - Parameter connectedClients: If provided, the latest connection is tracked here and can be sent messages from other threads.
    static func run(port: Int = defaultPort, connectedClients: ConnectedClients? = nil) throws {
        var env = try Environment.detect()
        let app = Application(env)
        defer { app.shutdown() }

        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = port

        let clients = connectedClients ?? ConnectedClients()
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
