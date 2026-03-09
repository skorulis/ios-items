// Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Models

let connectedClients = ConnectedClients()

private func baseItem(from input: String) -> BaseItem? {
    let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines)
    return BaseItem.allCases.first { item in
        String(describing: item) == normalized
            || item.name.lowercased() == normalized.lowercased()
    }
}
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

    let lower = input.lowercased()
    switch lower {
    case "help":
        print("Commands:")
        print("  help         – show this message")
        print("  status       – show number of connected clients")
        print("  getitems     – request items from the app client")
        print("  makeitem     – request client to create an item")
        print("  quit         – exit the debugger")
        print("  <text>       – send the text as a command to the app client")
    case "status":
        let count = connectedClients.count
        print("Connected clients: \(count)")
    case "getitems", "get_items", "get-items":
        connectedClients.send(request: .getItems)
        print("Requested items from client")
    case "makeitem":
        connectedClients.send(request: .makeItem)
    case "quit", "exit":
        print("Goodbye.")
        exit(0)
    default:
        print("Unknown command: \(input)")
    }

    print("> ", terminator: "")
}
