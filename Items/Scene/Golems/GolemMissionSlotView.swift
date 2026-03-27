// Created by Alexander Skorulis on 23/3/2026.

import Knit
import Models
import SwiftUI

@MainActor struct GolemMissionSlotView {
    let model: Model
    var viewModel: GolemsViewModel

    struct Model: Identifiable {
        let index: Int
        let slot: GolemMissionSlot
        let canStart: Bool

        var id: Int { index }
    }
}

extension GolemMissionSlotView: View {

    var body: some View {
        let slot = model.slot
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text("Golem \(model.index + 1)")
                    .font(.appSectionTitle)
                Spacer(minLength: 0)
                golemEquipmentButton
                if slot.phase == .running || slot.phase == .complete {
                    HStack(spacing: 8) {
                        missionStatisticsIconButton
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

    private var golemEquipmentButton: some View {
        Button {
            viewModel.openGolemEquipment(slotIndex: model.index)
        } label: {
            Image(systemName: "figure.arms.open")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Golem equipment")
    }

    private var missionStatisticsIconButton: some View {
        Button {
            viewModel.showMissionStatistics(slotIndex: model.index)
        } label: {
            Image(systemName: "chart.bar")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mission statistics")
    }

    private static let portalShardButtonIconSize: CGFloat = 22

    private func missionCostLabel(title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
            if let portalShard = Ingredient.portalShard.image {
                portalShard
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.portalShardButtonIconSize, height: Self.portalShardButtonIconSize)
                    .accessibilityHidden(true)
            }
        }
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
            locationSlot(slot: slot)

            HStack {
                Spacer(minLength: 0)
                Button {
                    viewModel.beginMission(slotIndex: model.index)
                } label: {
                    missionCostLabel(title: "Start mission")
                }
                .buttonStyle(CapsuleButtonStyle())
                .disabled(!model.canStart)
                .accessibilityLabel("Start mission, costs 1 portal shard")
            }
        }
    }

    private func runningBody(slot: GolemMissionSlot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            locationSlot(slot: slot)

            let isFighting = slot.enemies.contains { $0.distanceToGolemMeters <= GolemMissionSlot.enemyAttackRangeMeters }

            GolemMissionSideScrollerView(enemies: slot.enemies)

            Text(isFighting ? "Fighting" : "Walking")
                .font(.appCaption.weight(.semibold))
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
            locationSlot(slot: slot)

            Text("Mission complete")
                .font(.appCaption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer(minLength: 0)
                Button {
                    viewModel.beginMission(slotIndex: model.index)
                } label: {
                    missionCostLabel(title: "Restart mission")
                }
                .buttonStyle(CapsuleButtonStyle())
                .disabled(!model.canStart)
                .accessibilityLabel("Restart mission, costs 1 portal shard")
            }
        }
    }

    @ViewBuilder
    private func locationSlot(slot: GolemMissionSlot) -> some View {
        missionSlotColumn(
            title: "Location",
            accessibilityLabel: "Location",
            action: { viewModel.openMissionLocationPicker(slotIndex: model.index) },
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
        action: @escaping () -> Void,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appCaption.weight(.semibold))
                .foregroundStyle(.secondary)

            Button(action: action) {
                slotSquare { content() }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityLabel)
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

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemMissionSlotView(
        model: .init(index: 0, slot: .empty(), canStart: true),
        viewModel: assembler.resolver.golemsViewModel()
    )
    .padding()
}
