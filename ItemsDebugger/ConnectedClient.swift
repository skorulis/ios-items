//Created by Alexander Skorulis on 10/3/2026.

import Foundation
import Models
import Vapor

/// Thread-safe container for the current WebSocket connection (latest connection only).
final class ConnectedClient: @unchecked Sendable {
    private let lock = NSLock()
    private var client: Vapor.WebSocket?
    private var pendingResponses: [String: CheckedContinuation<ItemsClientResponse.Payload?, Never>] = [:]
    private var _cache = ConnectedClientCache()

    func setConnection(_ websocket: Vapor.WebSocket?) {
        lock.lock()
        client = websocket
        if websocket == nil {
            _cache = ConnectedClientCache()
        }
        lock.unlock()

        // When a client connects, automatically request the available actions/data.
        if websocket != nil {
            Task {
                _ = await self.send(request: .getActions)
            }
        }
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

    var cache: ConnectedClientCache {
        lock.lock()
        defer { lock.unlock() }
        return _cache
    }
    
    func send(request payload: ItemsClientRequest.Payload) async -> (ItemsClientResponse.Payload, CacheDiff)? {
        guard let result = await _send(request: payload) else {
            return nil
        }
        guard payload.isAction else {
            return (result, CacheDiff(links: nil))
        }
        let diff = await checkCacheDiff()
        return (result, diff)
    }
    
    private func checkCacheDiff() async -> CacheDiff {
        let oldActions = cache.links
        _ = await _send(request: .getActions)
        let newActions = cache.links
        let new = newActions.filter { !oldActions.contains($0) }
        
        if new.count > 0 {
            print("Found new actions: \(new)")
        }
        
        return CacheDiff(
            links: new.count > 0 ? new : nil
        )
    }

    private func _send(request payload: ItemsClientRequest.Payload) async -> ItemsClientResponse.Payload? {
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
        if case let .actions(actions, data) = response.payload {
            _cache.links = actions.map { Link(action: $0) } + data.map { Link(data: $0) }
        }
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

struct ConnectedClientCache: Sendable {
    var links: [Link] = []
}

struct CacheDiff {
    var links: [Link]?
}
