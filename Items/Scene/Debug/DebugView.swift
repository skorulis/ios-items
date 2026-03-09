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
            debuggerSection

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

            Button("Show toast") {
                viewModel.showTestToast()
            }
            .buttonStyle(CapsuleButtonStyle())

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var debuggerSection: some View {
        DebuggerConnectionSection(service: viewModel.debugConnectionService)
    }
}

// MARK: - Debugger connection section (observes service for state updates)

private struct DebuggerConnectionSection: View {
    let service: DebugConnectionService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Debugger connection")
                .font(.headline)
            TextField("Host", text: Binding(
                get: { service.host },
                set: { service.host = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .disableAutocorrection(true)

            HStack(spacing: 12) {
                switch service.connectionState {
                case .disconnected:
                    Button("Connect") {
                        service.connect()
                    }
                    .buttonStyle(CapsuleButtonStyle())
                case .connecting:
                    Text("Connecting…")
                        .foregroundStyle(.secondary)
                case .connected:
                    Button("Disconnect") {
                        service.disconnect()
                    }
                    .buttonStyle(CapsuleButtonStyle())
                    Text("Connected")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    return DebugView(viewModel: assembler.resolver.debugViewModel())
}

