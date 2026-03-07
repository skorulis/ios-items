//Created by Alexander Skorulis on 5/3/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct DebugView {
    @State var viewModel: DebugViewModel
}

// MARK: - Rendering

extension DebugView: View {

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(
            title: "Debug",
            backAction: nil
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button("Reset portal upgrades") {
                viewModel.resetUpgrades()
            }
            .buttonStyle(CapsuleButtonStyle())
            
            Button("Reset warehouse") {
                viewModel.mainStore.warehouse = .init()
            }
            .buttonStyle(CapsuleButtonStyle())
            
            Button("Add all items") {
                viewModel.addItems()
            }
            .buttonStyle(CapsuleButtonStyle())
            
            Button("Add all artifacts") {
                viewModel.addArtifacts()
            }
            .buttonStyle(CapsuleButtonStyle())

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    return DebugView(viewModel: assembler.resolver.debugViewModel())
}

