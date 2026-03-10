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

        // When a client connects, request actions and achievements so the cache has a baseline for diffing.
        if websocket != nil {
            Task {
                _ = await self.send(request: .getActions)
                _ = await self.send(request: .getAchievements)
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
            return (result, CacheDiff(links: nil, achievementsUnlocked: nil, achievementsNewlyVisible: nil))
        }
        let diff = await checkCacheDiff()
        return (result, diff)
    }
    
    private func checkCacheDiff() async -> CacheDiff {
        let oldLinks = cache.links
        let oldUnlocked = cache.achievementsUnlocked
        let oldVisibleIncomplete = cache.achievementsVisibleIncomplete

        _ = await _send(request: .getActions)
        _ = await _send(request: .getAchievements)

        let newLinks = cache.links
        let newUnlocked = cache.achievementsUnlocked
        let newVisibleIncomplete = cache.achievementsVisibleIncomplete

        let addedLinks = newLinks.filter { !oldLinks.contains($0) }
        let newlyUnlocked = newUnlocked.subtracting(oldUnlocked)
        let newlyVisible = newVisibleIncomplete.subtracting(oldVisibleIncomplete)

        if addedLinks.count > 0 {
            print("Found new actions: \(addedLinks)")
        }
        if !newlyUnlocked.isEmpty {
            print("Achievements unlocked: \(newlyUnlocked.map(\.rawValue))")
        }
        if !newlyVisible.isEmpty {
            print("Achievements newly visible: \(newlyVisible.map(\.rawValue))")
        }

        return CacheDiff(
            links: addedLinks.isEmpty ? nil : addedLinks,
            achievementsUnlocked: Array(newlyUnlocked).map { HTTPAchievement(achievement: $0) },
            achievementsNewlyVisible: Array(newlyVisible).map { HTTPAchievement(achievement: $0) },
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
        switch response.payload {
        case let .actions(actions, data):
            _cache.links = actions.map { Link(action: $0) } + data.map { Link(data: $0) }
        case let .achievements(completed, incomplete):
            _cache.achievementsUnlocked = Set(completed)
            _cache.achievementsVisibleIncomplete = Set(incomplete.map(\.achievement))
        default:
            break
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
    var achievementsUnlocked: Set<Achievement> = []
    var achievementsVisibleIncomplete: Set<Achievement> = []
}

struct CacheDiff: Codable {
    var links: [Link]?
    var achievementsUnlocked: [HTTPAchievement]?
    var achievementsNewlyVisible: [HTTPAchievement]?
}
