// Created by Alexander Skorulis on 9/3/2026.
//

import Foundation
import Models

final class InputListener {

    private let connectedClients: ConnectedClient

    init(connectedClients: ConnectedClient) {
        self.connectedClients = connectedClients
    }

    func start() {
        print("Type a command and press Enter. Commands: help, status, quit. Any other text is sent to connected app clients.")
        print("> ", terminator: "")

        while let line = readLine() {
            handle(line: line)
            print("> ", terminator: "")
        }
    }

    private func handle(line: String) {
        let input = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if input.isEmpty {
            return
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
            print("Requested items from client")
            perform(request: .getItems)
        case "getartifacts", "get_artifacts", "get-artifacts":
            print("Requested artifacts from client")
            perform(request: .getArtifacts)
        case "makeitem":
            print("Make item")
            perform(request: .makeItem)
        case "quit", "exit":
            print("Goodbye.")
            exit(0)
        default:
            print("Unknown command: \(input)")
        }
    }

    private func perform(request: ItemsClientRequest.Payload) {
        Task {
            _ = await connectedClients.send(request: request)
        }
    }

    private func baseItem(from input: String) -> BaseItem? {
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines)
        return BaseItem.allCases.first { item in
            String(describing: item) == normalized
                || item.name.lowercased() == normalized.lowercased()
        }
    }
}

