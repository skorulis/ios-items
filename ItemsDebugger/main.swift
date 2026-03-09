// Created by Alexander Skorulis on 9/3/2026.

import Foundation

let connectedClients = ConnectedClients()
let port = WebSocketServer.defaultPort

// Run the WebSocket server on a background thread (it blocks forever).
DispatchQueue.global(qos: .userInitiated).async {
    do {
        try WebSocketServer.run(port: port, connectedClients: connectedClients)
    } catch {
        print("Failed to start server: \(error)")
        exit(1)
    }
}

// Give the server a moment to bind.
Thread.sleep(forTimeInterval: 0.2)

let inputListener = InputListener(connectedClients: connectedClients)
inputListener.start()
