// Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Knit
import KnitMacros
import Models

private let defaultPort = 8765
private let debuggerHostKey = "debuggerHost"

@Observable
final class DebugConnectionService {

    enum ConnectionState {
        case disconnected
        case connecting
        case connected
    }

    private(set) var connectionState: ConnectionState = .disconnected
    var host: String {
        get {
            UserDefaults.standard.string(forKey: debuggerHostKey) ?? "localhost"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: debuggerHostKey)
        }
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private let clientRequestHandler: ClientRequestHandler

    @Resolvable<BaseResolver>
    init(clientRequestHandler: ClientRequestHandler) {
        self.clientRequestHandler = clientRequestHandler
        
        // Attempt to reconnect
        self.connect()
    }

    var isConnected: Bool {
        connectionState == .connected
    }

    func connect() {
        guard connectionState != .connecting && connectionState != .connected else { return }
        connectionState = .connecting

        let url = URL(string: "ws://\(host):\(defaultPort)")!
        let task = session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()

        Task { @MainActor in
            connectionState = .connected
            receiveLoop()
        }
    }

    @MainActor
    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                switch result {
                case let .success(message):
                    self.handle(message)
                    self.receiveLoop()
                case .failure:
                    self.connectionState = .disconnected
                    self.webSocketTask = nil
                }
            }
        }
    }

    @MainActor
    private func handle(_ message: URLSessionWebSocketTask.Message) {
        let data: Data?
        switch message {
        case let .string(text):
            data = text.data(using: .utf8)
        case let .data(raw):
            data = raw
        @unknown default:
            data = nil
        }

        guard let data else { return }

        let decoder = JSONDecoder()
        do {
            let request = try decoder.decode(ItemsClientRequest.self, from: data)
            let response = clientRequestHandler.handle(request: request)
            send(response: response)
        } catch {
            print("DebugConnectionService decode error: \(error)")
        }
    }

    private func send(response: ItemsClientResponse) {
        guard connectionState == .connected else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        do {
            let data = try encoder.encode(response)
            guard let json = String(data: data, encoding: .utf8) else {
                print("DebugConnectionService encode error: unable to build UTF-8 string from JSON data")
                return
            }

            webSocketTask?.send(.string(json)) { [weak self] _ in
                Task { @MainActor in
                    if self?.connectionState == .connected { }
                }
            }
        } catch {
            print("DebugConnectionService encode error: \(error)")
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionState = .disconnected
    }

    func send(_ string: String) {
        guard connectionState == .connected else { return }
        webSocketTask?.send(.string(string)) { [weak self] _ in
            Task { @MainActor in
                if self?.connectionState == .connected { }
            }
        }
    }
}
