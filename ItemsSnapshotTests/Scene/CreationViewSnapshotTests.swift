//Created by Alexander Skorulis on 03/3/2026.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct CreationViewSnapshotTests {
    
    let assembler = ItemsAssembly.testing()

    @Test
    func creationView_default() {
        let viewModel = assembler.resolver.creationViewModel()
        let view = CreationView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}
