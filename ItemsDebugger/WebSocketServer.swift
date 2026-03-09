// Created by Alexander Skorulis on 9/3/2026.

import Foundation
import LCLWebSocket
internal import NIOCore
internal import NIOWebSocket
internal import NIOHTTP1

/// Thread-safe container for the current WebSocket connection (latest connection only).
final class ConnectedClients: @unchecked Sendable {
    private let lock = NSLock()
    private var client: WebSocket?

    func setConnection(_ websocket: WebSocket?) {
        lock.lock()
        defer { lock.unlock() }
        client = websocket
    }

    func remove(_ websocket: WebSocket) {
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

    /// Sends text to the connected client. Safe to call from any thread. No-op if no client.
    func sendToAll(_ text: String) {
        lock.lock()
        let websocket = client
        lock.unlock()
        guard let websocket else { return }
        let message = text
        websocket.channel.eventLoop.execute {
            var buffer = websocket.channel.allocator.buffer(capacity: message.utf8.count)
            buffer.writeString(message)
            websocket.send(buffer, opcode: .text, promise: nil)
        }
    }
}

/// WebSocket server using [LCL WebSocket](https://github.com/Local-Connectivity-Lab/lcl-websocket).
enum WebSocketServer {

    static let defaultPort = 8765

    /// Starts the WebSocket server and blocks forever. Listens on all interfaces (0.0.0.0) so devices on the network can connect.
    /// - Parameter connectedClients: If provided, the latest connection is tracked here and can be sent messages from other threads.
    static func run(port: Int = defaultPort, connectedClients: ConnectedClients? = nil) throws {
        let config = LCLWebSocket.Configuration(
            maxFrameSize: 1 << 16,
            autoPingConfiguration: .disabled,
            leftoverBytesStrategy: .forwardBytes
        )

        let clients = connectedClients ?? ConnectedClients()
        var server = LCLWebSocket.server()
        server.onOpen { websocket in
            clients.setConnection(websocket)
            print("Client connected")
        }
        server.onClosed { }
        server.onText { _, text in
            print("Received text: \(text)")
        }
        server.onBinary { websocket, buffer in
            websocket.send(buffer, opcode: .binary, promise: nil)
        }
        server.onClosing { code, reason in
            print("Connection closing: \(String(describing: code)), \(String(describing: reason))")
        }

        print("WebSocket server listening on port \(port)")
        try server.listen(host: "0.0.0.0", port: port, configuration: config).wait()
    }
}
