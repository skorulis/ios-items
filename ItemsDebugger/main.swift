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

print("Type a command and press Enter. Commands: help, status, quit. Any other text is sent to connected app clients.")
print("> ", terminator: "")

while let line = readLine() {
    let input = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if input.isEmpty {
        print("> ", terminator: "")
        continue
    }

    switch input.lowercased() {
    case "help":
        print("Commands:")
        print("  help   – show this message")
        print("  status – show number of connected clients")
        print("  quit   – exit the debugger")
        print("  <text> – send the text as a command to all connected app clients")
    case "status":
        let count = connectedClients.count
        print("Connected clients: \(count)")
    case "quit", "exit":
        print("Goodbye.")
        exit(0)
    default:
        connectedClients.sendToAll(input)
        print("Sent to \(connectedClients.count) client(s): \(input)")
    }

    print("> ", terminator: "")
}
