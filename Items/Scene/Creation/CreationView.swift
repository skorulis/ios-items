// Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct CreationView {
    @State var viewModel: CreationViewModel

    struct CreationInProgress {
        let id: UUID
        let duration: TimeInterval
        let sacrificedItems: [BaseItem]

        var creationColors: [Color] {
            let fromSacrfice = sacrificedItems
                .flatMap { $0.essences }
                .map { $0.color }

            if fromSacrfice.isEmpty {
                return Essence.allCases.map { $0.color }
            } else {
               return fromSacrfice
            }
        }
    }

    struct Model {
        var createdItems: [MakeItemResult] = []
        var creationInProgress: CreationInProgress?

        var isCreating: Bool { creationInProgress != nil }

        var warehouse: Warehouse = Warehouse()
        var achievements: Achievements = Achievements()

        var recipesAvailable: Bool { achievements.unlocked.contains(.items10) }
        var upgradesAvailable: Bool { achievements.unlocked.contains(.items10) }

        /// Items created count; used for upgrades-corner progress toward `.items10` when the button is locked.
        var itemsCreatedCount: Int64 = 0

        /// Progress 0...1 toward unlocking `.items10` (Baby steps / upgrades button).
        var items10UnlockProgress: CGFloat {
            return CGFloat(itemsCreatedCount) / 10
        }
        var firstItem: Bool { !achievements.unlocked.contains(.items1) }
        var automationUnlocked: Bool = false
        var sacrificesUnlocked: Bool = false
        var showingResearch: Bool = false
        var mapLocationsUnlocked: Bool = false
        var mapLocations: MapLocations = MapLocations()
        var researchBadgeCount: Int = 0
        var researchUnderway: Bool = false
        var upgradesBadgeCount: Int = 0

        var maxArtifacts: Int = 0
        var artifactSlots: [ArtifactInstance?] {
            warehouse.equippedSlotsContents(upToSlotCount: maxArtifacts)
        }

        /// Latest sacrifice config + consumption plan for `SacrificesButton` (and overlays).
        var sacrificeConfig: SacrificeConfig = SacrificeConfig()
        var sacrificePlan: SacrificePlan = SacrificePlan(slotsByIndex: [:])

        var mapLocationsPurchasableCount: Int {
            MapLocation.allCases.filter { location in
                guard !mapLocations.isUnlocked(location) else { return false }
                return location.details.cost.allSatisfy { line in
                    warehouse.quantity(line.item) >= line.quantity
                }
            }
            .count
        }

    }

}

// MARK: - Rendering

extension CreationView: View {

    var body: some View {
        ZStack {
            PortalView(
                upgradesButton: upgradesButton,
                researchButton: viewModel.model.showingResearch
                    ? .init(
                        action: viewModel.showResearch,
                        badge: viewModel.model.researchUnderway
                            ? .count(viewModel.model.researchBadgeCount)
                            : .icon(Image(systemName: "exclamationmark")),
                        frameBinding: $viewModel.researchButtonFrame,
                    )
                    : nil,
                mapLocationsButton: viewModel.model.mapLocationsUnlocked
                    ? .init(
                        action: viewModel.showMapLocations,
                        badge: .count(viewModel.model.mapLocationsPurchasableCount),
                        frameBinding: $viewModel.mapLocationButtonFrame
                    )
                    : nil,
                sacrificesButton: sacrificesButton,
                sacrificesFrame: $viewModel.sacrificesButtonFrame,
            )
            artifactSlotsOverlay
            maybeCreationAnimation
            sacrificeAvatarsOverlay
            CreatedItemView(
                items: viewModel.model.createdItems,
                onDetailsTap: { viewModel.showDetails(item: $0) }
            )
            VStack {
                Spacer()
                makeButtonRow
            }
            .padding()

        }
        .coordinateSpace(name: "creation")
    }

    private var upgradesButton: PortalView.ButtonOrProgress? {
        if viewModel.model.items10UnlockProgress == 0 {
            return nil
        }
        return viewModel.model.upgradesAvailable
            ? .button(
                .init(
                    action: viewModel.showPortalUpgrades,
                    badge: .count(viewModel.model.upgradesBadgeCount),
                    frameBinding: $viewModel.upgradeButtonFrame,
                )
            )
            : .progress(
                viewModel.model.items10UnlockProgress,
                action: viewModel.showUpgradesProgressHelp
            )
    }

    private var artifactSlotView: ArtifactSlotView? {
        guard viewModel.model.artifactSlots.count > 0 else { return nil }
        return ArtifactSlotView(
            slots: viewModel.model.artifactSlots,
            size: .large,
            onSlotPressed: { viewModel.artifactSlotPressed(index: $0) }
        )
    }

    @ViewBuilder
    private var artifactSlotsOverlay: some View {
        if let artifactSlotView {
            VStack {
                artifactSlotView
                Spacer(minLength: 0)
            }
            .padding(.top, 48)
        }
    }

    private var sacrificesButton: SacrificesButton.Model? {
        guard viewModel.model.sacrificesUnlocked else {
            return nil
        }
        return SacrificesButton.Model(
            config: viewModel.model.sacrificeConfig,
            plan: viewModel.model.sacrificePlan,
            action: viewModel.showRecipes,
        )
    }

    @ViewBuilder
    private var maybeCreationAnimation: some View {
        if let creation = viewModel.model.creationInProgress {
            ParticleCanvasView(
                movementDuration: creation.duration,
                colors: creation.creationColors,
            )
            .id(creation.id)
        }
    }

    @ViewBuilder
    private var sacrificeAvatarsOverlay: some View {
        GeometryReader { geo in
            if let creation = viewModel.model.creationInProgress, !creation.sacrificedItems.isEmpty {
                let startPosition = CGPoint(
                    x: viewModel.sacrificesButtonFrame.minX,
                    y: viewModel.sacrificesButtonFrame.midY - 50,
                )
                let endPosition = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                SacrificeAnimationView(
                    items: creation.sacrificedItems,
                    startPosition: startPosition,
                    endPosition: endPosition,
                    duration: creation.duration,
                    animationId: creation.id
                )
            }
        }
        .allowsHitTesting(false)
    }

    private var makeButtonRow: some View {
        HStack(spacing: 12) {
            autoCreationButton
            createButton
            planButton
        }
    }

    private var autoCreationButton: some View {
        Button {
            viewModel.automateCreation.toggle()
        } label: {
            Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
                .font(.title2)
                .foregroundStyle(viewModel.automateCreation ? Color.green : Color.primary)
        }
        .buttonStyle(.plain)
        .opacity(viewModel.model.automationUnlocked ? 1 : 0)
    }

    private var planButton: some View {
        Button(action: viewModel.showCurrentRecipeDetail) {
            Image(systemName: "info.circle")
                .font(.title2)
        }
        .buttonStyle(.plain)
        .opacity(viewModel.model.firstItem ? 0 : 1)
    }

    private var createButton: some View {
        CreateButtonWithTimerBorder(
            timer: viewModel.model.automationUnlocked && viewModel.automateCreation
                ? viewModel.autoTimerProgress
                : nil,
            action: viewModel.make
        ) {
            ZStack {
                if viewModel.model.isCreating {
                    ProgressView()
                }
                Text(viewModel.model.firstItem ? "Unlock the portal" : "Summon item")
                    .opacity(viewModel.model.isCreating ? 0 : 1)
            }
        }
        .disabled(viewModel.model.isCreating)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    CreationView(viewModel: assembler.resolver.creationViewModel())
}
