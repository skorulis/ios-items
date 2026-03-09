// Created by Alexander Skorulis on 9/3/2026.

import Foundation
import Knit
import KnitMacros

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

    @Resolvable<BaseResolver>
    init() {}

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
                switch result {
                case .success:
                    self?.receiveLoop()
                case .failure:
                    self?.connectionState = .disconnected
                    self?.webSocketTask = nil
                }
            }
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
