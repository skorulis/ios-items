//Created by Alexander Skorulis on 7/3/2026.

import Knit
import Models
import SwiftUI

/// Picker shown when tapping an empty artifact slot. Lists discovered artifacts that are not already equipped.
@MainActor
struct ArtifactPickerView: View {
    @State var viewModel: ArtifactPickerViewModel
    @Environment(\.dismissCustomOverlay) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose artifact")
                .font(.headline)
                .padding(.horizontal, 16)

            ScrollView {
                ArtifactsListView(
                    warehouse: viewModel.warehouse,
                    artifacts: viewModel.availableArtifacts,
                    onArtifactPressed: { instance in
                        viewModel.select(artifact: instance)
                        dismiss()
                    }
                )
            }
            .frame(maxHeight: 400)
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Preview

#Preview {
    let assembler = ItemsAssembly.testing()
    var warehouse = assembler.resolver.mainStore().warehouse
    warehouse.add(artifact: ArtifactInstance(type: .frictionlessGear, quality: .good))
    warehouse.add(artifact: ArtifactInstance(type: .luckyCoin, quality: .common))
    assembler.resolver.mainStore().warehouse = warehouse
    return ArtifactPickerView(viewModel: assembler.resolver.artifactPickerViewModel(slot: 0))
}
