// Created by Alex Skorulis on 17/3/2026.

import Foundation

extension ProcessInfo {
    static var isRunningTests: Bool {
        ProcessInfo.processInfo.processName == "xctest" ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
