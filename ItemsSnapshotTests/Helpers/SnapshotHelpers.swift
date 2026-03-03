import SnapshotTesting
import SwiftUI
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
    column: UInt = #column
) {
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

