// Created by Alexander Skorulis on 23/3/2026.

import Knit
import Models
import SwiftUI

@MainActor struct GolemMissionSlotView {
    let slotIndex: Int
    var viewModel: GolemsViewModel
}

extension GolemMissionSlotView: View {

    var body: some View {
        let slot = viewModel.missionSlot(at: slotIndex)
        VStack(alignment: .leading, spacing: 12) {
            Text("Mission \(slotIndex + 1)")
                .font(.appSectionTitle)

            switch slot.phase {
            case .setup:
                setupBody(slot: slot)
            case .running:
                runningBody(slot: slot)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }

    private func setupBody(slot: GolemMissionSlot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Golem", selection: golemSelectionBinding) {
                Text("None").tag(Optional<GolemType>.none)
                ForEach(viewModel.selectableGolemTypes(for: slotIndex), id: \.self) { type in
                    Text(type.name).tag(GolemType?.some(type))
                }
            }
            .pickerStyle(.menu)

            Picker("Location", selection: locationSelectionBinding) {
                Text("None").tag(Optional<MapLocation>.none)
                ForEach(viewModel.unlockedMissionLocations(), id: \.self) { location in
                    Text(location.name).tag(MapLocation?.some(location))
                }
            }
            .pickerStyle(.menu)

            HStack {
                Spacer(minLength: 0)
                Button("Start mission") {
                    viewModel.startMission(slotIndex: slotIndex)
                }
                .buttonStyle(CapsuleButtonStyle())
                .disabled(!viewModel.canStartMission(slotIndex: slotIndex))
            }
        }
    }

    private func runningBody(slot: GolemMissionSlot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let golem = slot.golemType {
                Text(golem.name)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
            if let location = slot.location {
                Text(location.name)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.missionProgress(slotIndex: slotIndex))
                .tint(.accentColor)

            HStack {
                Spacer(minLength: 0)
                Button("Cancel") {
                    viewModel.cancelMission(slotIndex: slotIndex)
                }
                .buttonStyle(CapsuleButtonStyle())
            }
        }
    }

    private var golemSelectionBinding: Binding<GolemType?> {
        Binding(
            get: { viewModel.missionSlot(at: slotIndex).golemType },
            set: { viewModel.setReservedGolem(slotIndex: slotIndex, newType: $0) }
        )
    }

    private var locationSelectionBinding: Binding<MapLocation?> {
        Binding(
            get: { viewModel.missionSlot(at: slotIndex).location },
            set: { viewModel.setMissionLocation(slotIndex: slotIndex, location: $0) }
        )
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemMissionSlotView(slotIndex: 0, viewModel: assembler.resolver.golemsViewModel())
        .padding()
}
