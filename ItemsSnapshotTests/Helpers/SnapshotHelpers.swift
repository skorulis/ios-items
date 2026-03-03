import SnapshotTesting
import SwiftUI
import Testing
import UIKit

/// Convenience overload for snapshotting SwiftUI views.
func assertSnapshot<V: View>(
    of view: V,
    as snapshotting: Snapshotting<UIViewController, UIImage>,
    style: UIUserInterfaceStyle = .light,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
    sourceLocation: SourceLocation = #_sourceLocation,
) {
    // Enforce running on an iPhone 17 device to keep snapshots stable.
    let device = UIDevice.current
    guard let model = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] else {
        Issue.record(
            "Could not get simulator model",
            sourceLocation: sourceLocation,
        )
        return
    }
    
    guard model == "iPhone18,3" else {
        Issue.record(
            "Snapshots must run on iPhone 17",
            sourceLocation: sourceLocation,
        )
        return
    }

    let hostingController = UIHostingController(rootView: view)
    hostingController.overrideUserInterfaceStyle = style

    assertSnapshot(
        of: hostingController,
        as: snapshotting,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

