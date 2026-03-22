// Created by Alexander Skorulis on 22/3/2026.

import AmplitudeUnified
import Foundation
import Knit
import KnitMacros

protocol AnalyticsService {
    func track(event name: String, properties: [String: Any]?)
}

extension AnalyticsService {
    func track(event name: String) {
        self.track(event: name, properties: nil)
    }
}

final class AmplitudeAnalyticsService: AnalyticsService {

    private let amplitude: Amplitude
    private static let key = "beeb784a7ad2daf6859ec8f1e6702e65"

    @Resolvable<BaseResolver>
    init() {
        self.amplitude = Amplitude(apiKey: Self.key)
    }

    func track(event name: String, properties: [String: Any]? = nil) {
        amplitude.track(eventType: name, eventProperties: properties)
    }
}

final class FakeAnalyticsService: AnalyticsService {

    var events: [String] = []

    func track(event name: String, properties: [String: Any]? = nil) {
        events.append(name)
    }
}
