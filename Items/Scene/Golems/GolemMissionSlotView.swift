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
            HStack(alignment: .center, spacing: 8) {
                Text("Mission \(slotIndex + 1)")
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
            viewModel.showMissionActivityLog(slotIndex: slotIndex)
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
            viewModel.showMissionGainedItems(slotIndex: slotIndex)
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
            HStack(alignment: .top, spacing: 20) {
                missionSlotColumn(
                    title: "Golem",
                    accessibilityLabel: "Choose golem",
                    action: { viewModel.openMissionGolemPicker(slotIndex: slotIndex) },
                    content: {
                        if let type = slot.golemType, let image = type.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(8)
                        } else {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                )

                missionSlotColumn(
                    title: "Location",
                    accessibilityLabel: "Choose location",
                    action: { viewModel.openMissionLocationPicker(slotIndex: slotIndex) },
                    content: {
                        if let location = slot.location {
                            location.icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(8)
                                .symbolRenderingMode(.hierarchical)
                        } else {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                )
            }

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
            missionSlotReadOnlyRow(slot: slot)

            Text(slot.missionActivityState.displayTitle)
                .font(.appCaption)
                .foregroundStyle(.secondary)

            if let type = slot.golemType, let remaining = slot.remainingHealth {
                Text("Health: \(remaining) / \(type.missionMaxHealth)")
                    .font(.appCaption.weight(.semibold))
            }

            ProgressView(value: viewModel.missionHealthRemainingFraction(slotIndex: slotIndex))
                .tint(.accentColor)

            HStack {
                Spacer(minLength: 0)
                Button("Cancel") {
                    viewModel.presentCancelMissionConfirmation(slotIndex: slotIndex)
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
                Button("Clear") {
                    viewModel.clearCompletedMission(slotIndex: slotIndex)
                }
                .buttonStyle(CapsuleButtonStyle())
            }
        }
    }

    @ViewBuilder
    private func missionSlotReadOnlyRow(slot: GolemMissionSlot) -> some View {
        HStack(alignment: .top, spacing: 20) {
            missionSlotColumn(
                title: "Golem",
                accessibilityLabel: "Golem",
                action: nil,
                content: {
                    if let type = slot.golemType, let image = type.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                    }
                }
            )
            missionSlotColumn(
                title: "Location",
                accessibilityLabel: "Location",
                action: nil,
                content: {
                    if let location = slot.location {
                        location.icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            )
        }
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
        }
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemMissionSlotView(slotIndex: 0, viewModel: assembler.resolver.golemsViewModel())
        .padding()
}
