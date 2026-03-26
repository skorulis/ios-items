// Created by Alexander Skorulis on 23/3/2026.

import Knit
import Models
import SwiftUI

@MainActor struct GolemMissionSlotView {
    let model: Model
    var viewModel: GolemsViewModel

    struct Model: Identifiable {
        let index: Int

        var id: Int { index }
    }
}

extension GolemMissionSlotView: View {

    var body: some View {
        let slot = viewModel.missionSlot(at: model.index)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text("Golem \(model.index + 1)")
                    .font(.appSectionTitle)
                Spacer(minLength: 0)
                if slot.phase == .running || slot.phase == .complete {
                    HStack(spacing: 8) {
                        missionActivityLogIconButton
                        gainedItemsIconButton
                    }
                }
            }

            switch slot.phase {
            case .setup:
                setupBody(slot: slot)
            case .running:
                runningBody(slot: slot)
            case .complete:
                completeBody(slot: slot)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }

    private var missionActivityLogIconButton: some View {
        Button {
            viewModel.showMissionActivityLog(slotIndex: model.index)
        } label: {
            Image(systemName: "list.bullet.rectangle")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mission activity log")
    }

    private var gainedItemsIconButton: some View {
        Button {
            viewModel.showMissionGainedItems(slotIndex: model.index)
        } label: {
            Image(systemName: "archivebox")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Gained items")
    }

    private func setupBody(slot: GolemMissionSlot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            missionSlotColumn(
                title: "Location",
                accessibilityLabel: "Choose location",
                action: { viewModel.openMissionLocationPicker(slotIndex: model.index) },
                content: {
                    slot.location.icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .symbolRenderingMode(.hierarchical)
                }
            )

            HStack {
                Spacer(minLength: 0)
                Button("Start mission") {
                    viewModel.startMission(slotIndex: model.index)
                }
                .buttonStyle(CapsuleButtonStyle())
                .disabled(!viewModel.canStartMission(slotIndex: model.index))
            }
        }
    }

    private func runningBody(slot: GolemMissionSlot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            missionSlotReadOnlyRow(slot: slot)

            Text(slot.missionActivityState.displayTitle)
                .font(.appCaption)
                .foregroundStyle(.secondary)

            if let remaining = slot.remainingHealth {
                Text("Health: \(remaining) / \(GolemMissionSlot.missionMaxHealth)")
                    .font(.appCaption.weight(.semibold))
            }

            ProgressView(value: viewModel.missionHealthRemainingFraction(slotIndex: model.index))
                .tint(.accentColor)

            HStack {
                Spacer(minLength: 0)
                Button("Cancel") {
                    viewModel.presentCancelMissionConfirmation(slotIndex: model.index)
                }
                .buttonStyle(CapsuleButtonStyle())
            }
        }
    }

    private func completeBody(slot: GolemMissionSlot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            missionSlotReadOnlyRow(slot: slot)

            Text("Mission complete")
                .font(.appCaption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer(minLength: 0)
                Button("Restart (1 Portal Shard)") {
                    viewModel.restartCompletedMission(slotIndex: model.index)
                }
                .buttonStyle(CapsuleButtonStyle())
                .disabled(!viewModel.canRestartCompletedMission(slotIndex: model.index))
            }
        }
    }

    @ViewBuilder
    private func missionSlotReadOnlyRow(slot: GolemMissionSlot) -> some View {
        missionSlotColumn(
            title: "Location",
            accessibilityLabel: "Location",
            action: nil,
            content: {
                slot.location.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
                    .symbolRenderingMode(.hierarchical)
            }
        )
    }

    private static let slotSize: CGFloat = 64
    private static let slotStrokeWidth: CGFloat = 3

    @ViewBuilder
    private func missionSlotColumn(
        title: String,
        accessibilityLabel: String,
        action: (() -> Void)?,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.secondary)

            Group {
                if let action {
                    Button(action: action) {
                        slotSquare { content() }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel)
                } else {
                    slotSquare { content() }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(accessibilityLabel)
                }
            }
        }
    }

    private func slotSquare(@ViewBuilder content: () -> some View) -> some View {
        ZStack {
            Color(.systemBackground)
            content()
        }
        .frame(width: Self.slotSize, height: Self.slotSize)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.55), lineWidth: Self.slotStrokeWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private extension GolemMissionSlot.MissionActivityState {
    var displayTitle: String {
        switch self {
        case .exploring: return "Exploring"
        case .gathering: return "Gathering"
        case .accident:
            return "Having an accident"
        }
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemMissionSlotView(model: .init(index: 0), viewModel: assembler.resolver.golemsViewModel())
        .padding()
}
